addEvent("onIRCMessage")
addEventHandler("onIRCMessage",root,
        function (channel,message)
                if message:sub(1,1) == '!' and not ircIsEchoChannel(channel) then
					ircSay(channel,"12* New echo channel is " .. ircGetChannelName(ircGetEchoChannel()) .. " (dclick to join)")
                end
        end
)