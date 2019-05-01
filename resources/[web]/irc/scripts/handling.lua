---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

------------------------------------
-- Handling
------------------------------------
addEventHandler("onSockOpened",root,
        function (socket)
                for server,info in pairs (servers) do
                        if info[1] == socket then
                                servers[server][15] = true
                                if servers[server][5] then
                                        ircRaw(server,"PASS "..servers[server][5])
                                end
                                ircRaw(server,"USER echobot MCvarial MCv :Echobot by MCvarial")
                                ircRaw(server,"NICK "..info[4])
                                return
                        end
                end
        end
)

addEventHandler("onSockData",root,
        function (socket,data)
                if string.find(data,"Could not resolve your hostname: Domain name not found; using your IP address",0) then
                        localIP = string.sub(gettok(data,18,32),2,-2)
                end
                for server,info in pairs (servers) do
                        if info[1] == socket then
                                for i,line in ipairs (split(data,10)) do
                                        if line ~= "" then
                                                triggerEvent("onIRCRaw",server,line)
                                        end
                                end
                                return
                        end
                end
        end
)

addEvent("onIRCRaw")
addEventHandler("onIRCRaw",root,
        function (data)
                servers[source][11] = getTickCount()
                
                local t = split(data,32)
                if t[1] == "PING" then
                        if t[2] then
                                ircRaw(source,"PONG "..string.sub(t[2],2))
                        else
                                ircRaw(source,"PONG :REPLY")
                        end
                end
                if t[2] == "376" then
                        --users[(createElement("irc-user"))] = {ircGetServerNick(source),"+iwxz","?","?","?",{}}
                        triggerEvent("onIRCConnect",source)
                end
                if t[2] == "001" then
                        servers[source][2] = t[7]
                        servers[source][15] = true
                end
                if t[2] == "002" then
                        servers[source][3] = string.sub(t[7],1,-2)
                end
                if t[2] == "JOIN" then
                        local nick = getNickFromRaw(data)
                        local user = ircGetUserFromNick(nick)
                        local channel = ircGetChannelFromName(getMessageFromRaw(data))
                        local vhost = gettok(gettok(data,1,32),2,33)
                        if nick == ircGetServerNick(source) then
                                if not channel then
                                        table.insert(servers[source][14],getMessageFromRaw(data))
                                        channel = createElement("irc-channel")
                                        channels[channel] = {getMessageFromRaw(data),"+nst","Unknown",{},false,true,false}
                                        setElementParent(channel,source)
                                end
                        end
                        if user then
                                users[user][3] = vhost
                                table.insert(users[user][6],channel)
                        else
                                user = createElement("irc-user")
                                users[user] = {nick,"+iwxz",vhost,"?","?",{channel}}
                                setElementParent(user,source)
                        end
                        triggerEvent("onIRCUserJoin",user,channel,vhost)
                end
                if t[2] == "NICK" then
                        local oldnick = getNickFromRaw(data)
                        local newnick = string.sub(t[3],1,-2)
                        local user = ircGetUserFromNick(oldnick)
                        users[user][1] = newnick
                        triggerEvent("onIRCUserChangeNick",user,oldnick,newnick)
                end
                if t[2] == "PART" then
                        local user = ircGetUserFromNick(getNickFromRaw(data))
                        local reason = getMessageFromRaw(data)
                        local channel = ircGetChannelFromName(t[3]) or ircGetChannelFromName(string.sub(t[3],1,-2))
                        for i,chan in ipairs (users[user][6]) do
                                if channel == chan then
                                        table.remove(users[user][6],i)
                                        break
                                end
                        end
                        if userlevels[channel][user] then
                                userlevels[channel][user] = nil
                        end
                        triggerEvent("onIRCUserPart",user,channel,reason)
                end
                if t[2] == "KICK" then
                        local user = ircGetUserFromNick(t[4])
                        local reason = getMessageFromRaw(data)
                        local channel = ircGetChannelFromName(t[3])
                        local kicker = ircGetUserFromNick(getNickFromRaw(data))
                        for i,chan in ipairs (users[user][6]) do
                                if channel == chan then
                                        table.remove(users[user][6],i)
                                        break
                                end
                        end
                        triggerEvent("onIRCUserKick",user,channel,reason,kicker)
                        if t[4] == ircGetServerNick(source) then
                                ircJoin(source,t[3])
                        end
                end
                if t[2] == "353" then
                        local nicks = split(getMessageFromRaw(data),32)
                        local channel = ircGetChannelFromName(t[5])
                        for i,nick in ipairs (nicks) do
                                local nick,level = getNickAndLevel(nick)
                                local user = ircGetUserFromNick(nick)
                                if user then
                                        table.insert(users[user][6],channel)
                                else
                                        user = createElement("irc-user")
                                        users[user] = {nick,"+iwxz","?","?","?",{channel}}
                                        setElementParent(user,source)
                                end
                                if not userlevels[channel] then
                                        userlevels[channel] = {}
                                end
                                if not userlevels[channel][user] then
                                        userlevels[channel][user] = 0
                                end
                                if userlevels[channel][user] ~= level then
                                        triggerEvent("onIRCLevelChange",user,channel,userlevels[channel][user],level)
                                        userlevels[channel][user] = level
                                end
                        end
                end
                if t[2] == "433" then
                        triggerEvent("onIRCFailConnect",source,"Nickname already in use")
                        ircChangeNick(source,t[4].."_")
                        if servers[source][8] then
                                ircRaw(source,"PRIVMSG NickServ :GHOST "..t[4].." "..servers[source][8])
                                ircChangeNick(source,t[4])
                        end
                end
                if t[2] == "PRIVMSG" then
                        local user = ircGetUserFromNick(getNickFromRaw(data))
                        local message = getMessageFromRaw(data)
                        local channel = ircGetChannelFromName(t[3])
                        if t[3] == ircGetServerNick(source) then
                                triggerEvent("onIRCPrivateMessage",user,message)
                        else
                                triggerEvent("onIRCMessage",user,channel,message)
                        end
                end
                if t[2] == "NOTICE" then
                        local user = ircGetUserFromNick(getNickFromRaw(data))
                        if user then
                                if t[3] == ircGetServerNick(source) then
                                        triggerEvent("onIRCPrivateNotice",user,getMessageFromRaw(data))
                                else
                                        triggerEvent("onIRCNotice",user,ircGetChannelFromName(t[3]),getMessageFromRaw(data))
                                end
                        end
                end
                if t[2] == "QUIT" then
                        local nick = getNickFromRaw(data)
                        local user = ircGetUserFromNick(nick)
                        triggerEvent("onIRCUserQuit",user,getMessageFromRaw(data))
                        users[user] = nil
                        destroyElement(user)
                        if nick == string.sub(ircGetServerNick(source),1,-2) then
                                ircChangeNick(source,nick)
                        end
                        if userlevels[channel] and userlevels[channel][user] then
                                userlevels[channel][user] = nil
                        end
                end
                if t[1] == "ERROR" then
                        triggerEvent("onIRCFailConnect",source,getMessageFromRaw(data))
                end
        end
)

addEvent("onIRCConnect")
addEventHandler("onIRCConnect",root,
        function ()
                for i,raw in ipairs (servers[source][16]) do
                        ircRaw(source,raw)
                end
                servers[source][16] = {}
        end
)

setTimer(function ()
        for i,server in ipairs (ircGetServers()) do
                if not servers[server] or not servers[server][11] then return end
                -- This causes error spamming
                -- Why is the IRC resource even in use anymore?
                if (getTickCount() - servers[server][11]) > 180000 then
                        servers[server][11] = getTickCount()
                        ircReconnect(server,"Connection timed out")
                elseif (getTickCount() - servers[server][11]) > 120000 then
                        ircRaw(server,"PING")
                end
        end
end,30000,0)