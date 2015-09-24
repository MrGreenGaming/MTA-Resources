---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------
addEventHandler("onIRCConnecting",root,
	function ()
		outputServerLog("IRC: connecting to '"..ircGetServerHost(source).."' on port "..ircGetServerPort(source).."...")
	end
)

addEventHandler("onIRCConnect",root,
	function ()
		outputServerLog(ircGetServerName(source)..": Connected as "..getServerNickName(source).."!")
	end
)

addEvent("aMessage",true)
addEventHandler("aMessage",root,
	function (type,t)
		if type == "new" then
			outputServerLog("ADMIN MESSAGE: new "..(t.category).." from "..getPlayerName(source)..". Subject: "..(t.subject))
		end
	end
)