---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

-- everything is saved here
servers = {} -- syntax: [server] = {element socket,string name,string host,string nick,string password,number port,bool secure,string nickservpass,string authident, string authpass,number lastping,timer timeoutguard,number reconnectattempts, table channels,bool connected,table buffer}
channels = {} -- syntax: [channel] = {string name,string mode,string topic,table users,string password,bool joined,bool echo}
users = {} -- syntax: [user] = {string name,string mode,string vhost,string email,string realname,table channels,table channelmodes}

------------------------------------
-- Loading
------------------------------------
addEventHandler("onResourceStart",resourceRoot,
        function ()
                -- Is the sockets module loaded?
                if not sockOpen then
                        outputServerLog("IRC: could not start resource, the sockets module isn't loaded!")
                        outputServerLog("IRC: restart the resource to retry")
                        return
                end
                
                -- Parse functions file.
                local functionsFile = fileOpen("scripts/functions.txt",true)
                if functionsFile then
                        for i,line in ipairs (split(fileRead(functionsFile,fileGetSize(functionsFile)),44)) do
                                local functionName = gettok(line,2,32)
                                _G[(functionName)] = function (...)
                                        local args = {...}
                                        for i,arg in ipairs (args) do
                                                local expectedArgType = gettok(line,(2+i),32)
                                                if type(arg) ~= expectedArgType and not string.find(expectedArgType,")") then
                                                        outputServerLog("IRC: Bad argument #"..i.." @ '"..gettok(line,2,32).."' "..expectedArgType.." expected, got "..type(arg))
                                                        return
                                                end
                                        end
                                        return _G[("func_"..functionName)](...)
                                end
                        end
                        fileClose(functionsFile)
                else
                        outputServerLog("IRC: could not start resource, the functions file can't be loaded!")
                        outputServerLog("IRC: restart the resource to retry")
                        return
                end
                
                -- Connect when needed.
                if get("irc-autoconnect") == "true" then
                        internalConnect()
                end
        end
)

addEventHandler("onResourceStop",resourceRoot,
        function ()
                for i,server in ipairs (ircGetServers()) do
                        ircDisconnect(server,"resource stopped")
                end
        end
)

function internalConnect ()
        -- Parse settings file.
        local settingsFile = xmlLoadFile("settings.xml")
        if settingsFile then
                for i,server in ipairs (xmlNodeGetChildren(settingsFile)) do
                        local host = xmlNodeGetAttribute(server,"host")
                        local nick = xmlNodeGetAttribute(server,"nick")
                        local channels = xmlNodeGetAttribute(server,"channels")
                        local port = tonumber(xmlNodeGetAttribute(server,"port")) or 6667
                        local password = xmlNodeGetAttribute(server,"password") or false
                        local secure = xmlNodeGetAttribute(server,"secure") or false
                        local nspass = xmlNodeGetAttribute(server,"nickservpass") or false
                        if not host then
                                outputServerLog("IRC: problem with server #"..i..", no host given!")
                        elseif not nick then
                                outputServerLog("IRC: problem with server #"..i..", no nick given!")
                        elseif not channels then
                                outputServerLog("IRC: problem with server #"..i..", no channels given!")
                        else
                                local server = ircConnect(host,nick,port,password,secure)
                                if nspass then
                                        ircIdentify(server,nspass)
                                end
                                for i,channel in ipairs (split(channels,44)) do
                                        ircJoin(server,gettok(channel,1,32),gettok(channel,2,32))
                                end
                        end
                end
                xmlUnloadFile(settingsFile)
        else
                outputServerLog("IRC: could not start resource, the settings.xml can't be parsed!")
                outputServerLog("IRC: restart the resource to retry")
                return
        end
end

------------------------------------
-- Socket events
------------------------------------
addEventHandler("onSockOpened",root,
        function (socket)
                for server,info in pairs (servers) do
                        if info[1] == socket then
                                servers[server][15] = true
                                ircRaw(server,"USER echobot MCvarial MCv :Echobot by MCvarial");
                                ircRaw(server,"NICK "..info[4])
                                return
                        end
                end
        end
)

addEventHandler("onSockData",root,
        function (socket,data)
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

addEventHandler("onSockClosed",root,
        function (socket)
                for server,info in pairs (servers) do
                        if info[1] == socket then
                                ircDisconnect(server,"Socket closed")
                                return
                        end
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
