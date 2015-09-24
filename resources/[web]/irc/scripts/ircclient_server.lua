---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

local ircers = {}
local chantitles = {}

------------------------------------
-- Irc client
------------------------------------
addEvent("startIRCClient",true)
addEventHandler("startIRCClient",root,
        function ()
                if get("irc-client") == "true" then
                        local info = {} -- {channeltitle,{users}}
                        for i,channel in ipairs (ircGetChannels()) do
                                local users = {}
                                for i,user in ipairs (ircGetUsers()) do
                                        users[i] = {ircGetUserNick(user),ircGetUserLevel(user,channel)}
                                end
                                local chantitle = ircGetChannelName(channel).." - "..ircGetServerName(ircGetChannelServer(channel))
                                table.insert(info,{chantitle,users})
                                chantitles[chantitle] = channel
                        end
                        triggerClientEvent(source,"showIrcClient",root,info)
                        table.insert(ircers,source)
                end
        end
)

addCommandHandler("ircsay",
	function (source,cmd,...)
		local message = table.concat({...}," ")
		if message then
			outputIRC(getPlayerName(source)..": "..message)
		else
			outputChatBox("* syntax is /ircsay <message>",source,255,100,70)
		end
	end,false,false
)

addEvent("ircSay",true)
addEventHandler("ircSay",root,
	function (chantitle,message)
		ircSay(chantitles[chantitle],getPlayerName(source)..": "..message)
	end
)

addEventHandler("onIRCMessage",root,
	function (channel,message)
		triggerIRCEvent("onClientIRCMessage",ircGetUserNick(source),ircGetChannelTitle(channel),message)
	end
)

addEventHandler("onIRCUserJoin",root,
	function (channel,vhost)
		triggerIRCEvent("onClientIRCUserJoin",ircGetUserNick(source),ircGetChannelTitle(channel),vhost)
	end
)

addEventHandler("onIRCUserPart",root,
	function (channel,reason)
		triggerIRCEvent("onClientIRCUserPart",ircGetUserNick(source),ircGetChannelTitle(channel),reason)
	end
)

addEventHandler("onIRCUserQuit",root,
	function (reason)
		triggerIRCEvent("onClientIRCUserQuit",ircGetUserNick(source),reason)
	end
)

addEventHandler("onIRCNotice",root,
	function (channel,message)
		triggerIRCEvent("onClientIRCNotice",ircGetUserNick(source),ircGetChannelTitle(channel),message)
	end
)

addEventHandler("onIRCUserMode",root,
	function (channel,positive,mode,setter)
		if setter then
			triggerIRCEvent("onClientIRCUserMode",ircGetUserNick(source),ircGetChannelTitle(channel),positive,mode,ircGetUserNick(setter))
		else
			triggerIRCEvent("onClientIRCUserMode",ircGetUserNick(source),ircGetChannelTitle(channel),positive,mode,"Server")
		end
	end
)

addEventHandler("onIRCChannelMode",root,
	function (positive,mode,setter)
		triggerIRCEvent("onClientIRCChannelMode",ircGetChannelTitle(source),positive,mode,ircGetUserNick(setter))
	end
)

addEvent("onIRCLevelChange")
addEventHandler("onIRCLevelChange",root,
	function (channel,oldlevel,newlevel)
		triggerIRCEvent("onClientIRCLevelChange",ircGetUserNick(source),ircGetChannelTitle(channel),oldlevel,newlevel)
	end
)

addEventHandler("onIRCUserChangeNick",root,
	function (oldnick,newnick)
		triggerIRCEvent("onClientIRCUserChangeNick",oldnick,newnick)
	end
)

function triggerIRCEvent (eventname,...)
	for i,ircer in ipairs (ircers) do
		if isElement(ircer) then
			triggerClientEvent(ircer,eventname,root,...)
		end
	end
	return true
end

function ircGetChannelTitle (channel)
	return tostring(ircGetChannelName(channel)).." - "..tostring(ircGetServerName(ircGetChannelServer(channel)))
end