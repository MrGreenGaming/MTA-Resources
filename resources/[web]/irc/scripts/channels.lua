---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

-- everything is saved here
channels = {} -- syntax: [channel] = {string name,string mode,string topic,table users,string password,bool joined,bool echo}

------------------------------------
-- Channels
------------------------------------
function func_ircGetChannelFromName (channel)
        for i,chan in ipairs (ircGetChannels()) do
                if ircGetChannelName(chan) == channel then
                        return chan
                end
        end
        return false
end

function func_ircGetEchoChannel ()
        for i,channel in ipairs (ircGetChannels()) do
                if ircIsEchoChannel(channel) then
                        return channel
                end
        end
        return false
end

function func_ircGetChannelServer (channel)
        if channels[channel] then
                return getElementParent(channel)
        end
        return false
end

function func_ircGetChannels (server)
        if servers[server] then
                local channels = {}
                for i,channels in ipairs (ircGetChannels()) do
                        if ircGetChannelServer(channel) == server then
                                table.insert(channels,channel)
                        end
                end
                return channel
        end
        return getElementsByType("irc-channel")
end

function func_ircSetChannelMode (channel,mode)
        if channels[channel] and type(mode) == "string" then
                return ircRaw(getElementParent(channel),"MODE "..channels[channel][1].." :"..mode)
        end
        return false
end

function func_ircGetChannelName (channel)
        if channels[channel] then
                return channels[channel][1]
        end
        return false
end

function func_ircGetChannelMode (channel)
        if channels[channel] then
                return channels[channel][2]
        end
        return false
end

function func_ircGetChannelUsers (channel)
        if channels[channel] then
                return channels[channel][4]
        end
        return false
end

function func_ircGetChannelTopic (channel)
        if channels[channel] then
                return channels[channel][3]
        end
        return false
end

function func_ircIsEchoChannel (channel)
        if channels[channel] then
                return channels[channel][7]
        end
        return false
end
