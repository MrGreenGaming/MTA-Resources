---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

local adTimer

------------------------------------
-- Loading
------------------------------------
addEventHandler("onResourceStart",resourceRoot,
        function ()
        -- Parse rights file.
                local rightsFile = fileOpen("scripts/rights.txt",true)
                if rightsFile then
                        local missingRights = {}
                        for i,line in ipairs (split(fileRead(rightsFile,fileGetSize(rightsFile)),44)) do
                                line = string.sub(line,2)
                                if not hasObjectPermissionTo(getThisResource(),"function."..line,true) then
                                        table.insert(missingRights,"function."..line)
                                end
                        end
                        if #missingRights ~= 0 then
                                outputServerLog("IRC: "..#missingRights.." missing rights: ")
                                for i,missingRight in ipairs (missingRights) do
                                        outputServerLog("       - "..missingRight)
                                end
                                outputServerLog("Please give the irc resource these rights or it will not work properly!")
                        end
                else
                        outputServerLog("IRC: could not start resource, the rights file can't be loaded!")
                        outputServerLog("IRC: restart the resource to retry")
                        return
                end
                
                -- Is the resource up-to-date?
                function checkVersion (res,version)
                        if res ~= "ERROR" and version then
                                if getNumberFromVersion(version) > getNumberFromVersion(getResourceInfo(getThisResource(),"version")) then
                                        outputServerLog("IRC: resource is outdated, newest version: "..version)
                                        setTimer(outputIRC,10000,1,"The irc resource is outdated, newest version: "..version)
                                end
                        end
                end
                --callRemote("http://community.mtasa.com/mta/resources.php",checkVersion,"version","irc")
                
                -- Start the ads.
                addEvent("onIRCPlayerDelayedJoin",true)
                if get("irc-notice") == "true" then
                        local timeout = tonumber(get("irc-notice-timeout"))
                        if timeout then
                                if timeout == 0 then
                                        addEventHandler("onIRCPlayerDelayedJoin",root,showContinuousAd)
                                else
                                        adTimer = setTimer(showAd,timeout*1000,0)
                                end
                        end
                end
                
                -- Parse functions file.
                local functionsFile = fileOpen("scripts/functions.txt",true)
                if functionsFile then
                        for i,line in ipairs (split(fileRead(functionsFile,fileGetSize(functionsFile)),44)) do
                                if gettok(line,1,21) ~= "--" then
                                        local functionName = gettok(line,2,32)
                                        _G[(functionName)] = function (...)
                                                local args = {...}
                                                for i,arg in ipairs (args) do
                                                        local expectedArgType = gettok(line,(2+i),32)
                                                        if expectedArgType and type(arg) ~= expectedArgType and not (expectedArgType or string.find(expectedArgType,")")) then
                                                                outputServerLog("IRC: Bad argument #"..i.." @ '"..gettok(line,2,32).."' "..expectedArgType.." expected, got "..type(arg))
                                                                return
                                                        end
                                                end
                                                if _G[("func_"..functionName)] then
                                                        return _G[("func_"..functionName)](...)
                                                else
                                                        outputServerLog("Function '"..functionName.."' does not exist")
                                                        return false
                                                end
                                        end
                                end
                        end
                        fileClose(functionsFile)
                else
                        outputServerLog("IRC: could not start resource, the functions file can't be loaded!")
                        outputServerLog("IRC: restart the resource to retry")
                        return
                end
                
                -- parse acl file
                local aclFile = xmlLoadFile("acl.xml")
                if  aclFile then
                        local i = 0
                        -- for each command we find
                        while(xmlFindChild(aclFile,"command",i)) do
                                local child = xmlFindChild(aclFile,"command",i)
                                local attrs = xmlNodeGetAttributes(child)
                                acl[attrs.name] = attrs
                                i = i + 1
                        end
                        xmlUnloadFile(aclFile)
                else
                        outputServerLog("IRC: could not start resource, the acl file can't be loaded!")
                        outputServerLog("IRC: restart the resource to retry")
                        return
                end
                
                -- Is the sockets module loaded?
                if not sockOpen then
                        outputServerLog("IRC: could not start resource, the sockets module isn't loaded!")
                        outputServerLog("IRC: restart the resource to retry")
                        return
                end
                
                -- start irc addons
                for i,resource in ipairs (getResources()) do
                        local info = getResourceInfo(resource,"addon")
                        if info and info == "irc" then
                                startResource(resource)
                        end
                end

                triggerEvent("onIRCResourceStart",root)
				addIRCCommands()
                internalConnect()
        end
)

addEventHandler("onResourceStop",resourceRoot,
        function ()
                for i,server in ipairs (ircGetServers()) do
                        ircDisconnect(server,"resource stopped")
                end
                servers = {}
                channels = {}
                users = {}
                
                -- stop irc addons
                for i,resource in ipairs (getResources()) do
                        local info = getResourceInfo(resource,"addon")
                        if info and info == "irc" then
                                stopResource(resource)
                        end
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
                                if server then
                                        if nspass then
                                                ircIdentify(server,nspass)
                                        end
                                        for i,channel in ipairs (split(channels,44)) do
                                                ircJoin(server,gettok(channel,1,32),gettok(channel,2,32))
                                        end
                                else
                                        outputServerLog("IRC: problem with server #"..i..", could not connect ("..tostring(getSocketErrorString(sockError)..")"))
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

function showAd ()
        for i,channel in ipairs (ircGetChannels()) do
                if ircIsEchoChannel(channel) then
                        --outputChatBox("Join us on irc! Server: "..ircGetServerHost(ircGetChannelServer(channel)).." Channel: "..ircGetChannelName(channel),root,0,255,0)
                        triggerClientEvent("showAd",root,ircGetServerHost(ircGetChannelServer(channel)),ircGetChannelName(channel),tonumber(get("irc-notice-duration")))
                        return
                end
        end
end

function showContinuousAd ()
        for i,channel in ipairs (ircGetChannels()) do
                if ircIsEchoChannel(channel) then
                        triggerClientEvent(source,"showAd",root,ircGetServerHost(ircGetChannelServer(channel)),ircGetChannelName(channel),0)
                        return
                end
        end
end