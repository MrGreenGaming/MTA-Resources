---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

userlevels = {} -- userlevels[channel] = int level
usermodes = {}
local userflags = {"q","a","o","h","v","b","e"}

------------------------------------
-- Levels
------------------------------------
addEvent("onIRCRaw")
addEventHandler("onIRCRaw",root,
        function (raw)
                local t = split(string.sub(raw,1,-2),32)
                if t[2] == "MODE" then
                        ircRaw(source,"NAMES "..t[3])
                        local channel = ircGetChannelFromName(t[3])
                        local setter = ircGetUserFromNick(getNickFromRaw(raw))
                        local modes = toletters(t[4])
                        local positive = true
                        table.remove(t,1)
                        table.remove(t,1)
                        table.remove(t,1)
                        table.remove(t,1)
                        for i,nick in ipairs (t) do
                                local mode = modes[i]
                                if mode == "+" then
                                        positive = true
                                        table.remove(modes,i)
                                        mode = modes[i]
                                end
                                if mode == "-" then
                                        positive = false
                                        table.remove(modes,i)
                                        mode = modes[i]
                                end
                                for i=1,#modes do
                                        if isChanMode(mode) then
                                                triggerEvent("onIRCChannelMode",channel,positive,mode,setter)
                                                table.remove(modes,i)
                                                mode = modes[i]
                                        end
                                end
                                if mode == "b" then
                                        triggerEvent("onIRCBan",channel,positive,nick,setter)
                                else
                                        triggerEvent("onIRCUserMode",ircGetUserFromNick(nick),channel,positive,mode,setter)
                                end
                        end
                        if #t == 0 and channel then
                                for i,mode in ipairs (modes) do
                                        if mode == "+" then
                                                positive = true
                                                table.remove(modes,i)
                                                mode = modes[i]
                                        end
                                        if mode == "-" then
                                                positive = false
                                                table.remove(modes,i)
                                                mode = modes[i]
                                        end
                                        triggerEvent("onIRCChannelMode",channel,positive,mode)
                                end
                        end
                end
        end
)

function func_ircGetUserLevel (user,channel)
        if userlevels[channel] then
                return userlevels[channel][user]
        end
        return 0
end

function isChanMode (mode)
        for i,usermode in ipairs (userflags) do
                if usermode == mode then
                        return false
                end
        end
        return true
end
