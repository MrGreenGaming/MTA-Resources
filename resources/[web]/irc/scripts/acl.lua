---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

acl = {}
local commands = {}

------------------------------------
-- Acl
------------------------------------
function func_addIRCCommandHandler (cmd,fn,level,echochanonly)
        if not acl[cmd] then
                acl[cmd] = {name = cmd,level = level,echoChannelOnly = echochannelonly}
        end
        commands[cmd] = fn
        return true
end

function func_ircGetCommands ()
        local cmds = {}
        for cmd,fn in pairs (commands) do
                table.insert(cmds,cmd)
        end
        return cmds
end

function func_ircGetCommandLevel (cmd)
        if acl[cmd] then
                return tonumber(acl[cmd].level) or 0
        end
        return false
end

function func_ircIsCommandEchoChannelOnly (cmd)
        if acl[cmd] then
                return acl[cmd].echoChannelOnly
        end
        return false
end
        
addEvent("onIRCMessage")
addEventHandler("onIRCMessage",root,
        function (channel,message)
                if gettok(ircGetUserVhost(source),1,64) == 'echobot' then return end --ignore ourselves
                local cmd = gettok(message,1,32)
                local args = split(message,32)
                if commands[cmd] and acl[cmd] and acl[cmd].level and (tonumber(acl[cmd].level) or 0) <= (tonumber(ircGetUserLevel(source,channel)) or 0) then
                        if ircIsCommandEchoChannelOnly(cmd) then
                                if ircIsEchoChannel(channel) then
                                        commands[cmd](ircGetChannelServer(channel),channel,source,unpack(args))
                                end
                        else
                                commands[cmd](ircGetChannelServer(channel),channel,source,unpack(args))
                        end
                elseif ircIsEchoChannel(channel) and message:sub(1, 1) ~= '!' then
                        say(ircGetChannelServer(channel),channel,source,'say',message)
                end
        end
)