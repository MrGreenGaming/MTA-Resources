---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.0
-- Date: 31.10.2010
---------------------------------------------------------------------

------------------------------------
-- Echo
------------------------------------
function getNameNoColor(player)
	return string.gsub (isElement(player) and getPlayerName(player) or '^', '#%x%x%x%x%x%x', '' )
end

addEventHandler("onResourceStart",root,
        function (resource)
                if getResourceInfo(resource,"type") ~= "map" then
                        outputIRC("07* Resource '"..getResourceName(resource).."' started!")
                end
        end
)

addEventHandler("onResourceStop",root,
        function (resource)
                if getResourceInfo(resource,"type") ~= "map" then
                        outputIRC("07* Resource '"..(getResourceName(resource) or "?").."' stopped!")
                end
        end
)

addEventHandler("onPlayerJoin",root,
    function ()
        local country = exports.geoloc:getPlayerCountryName(source)
		if country then 
			outputIRC("03*** "..getNameNoColor(source).." joined from "..country..". ["..getPlayerCount().."/"..getMaxPlayers().."]")
		else	
    		outputIRC("03*** "..getNameNoColor(source).." joined the game. ["..getPlayerCount().."/"..getMaxPlayers().."]")
		end
    end
)

addEventHandler("onPlayerQuit",root,
        function (quit,reason,element)
        if reason then
			outputIRC("02*** "..getNameNoColor(source).." was "..quit.." from the game by "..getNameNoColor(element).." ("..reason..")".." ["..(getPlayerCount()-1).."/"..getMaxPlayers().."]")
		else
			if getElementData(source, 'gotomix') then
				quit = 'Going to ' .. string.lower(get('interchat.other_server')) .. ' server'
			end	
			outputIRC("02*** "..getNameNoColor(source).." left the game ("..quit..")".." ["..(getPlayerCount()-1).."/"..getMaxPlayers().."]")
		end
        end
)

addEventHandler("onPlayerChangeNick",root,
        function (oldNick,newNick)
                outputIRC("13* "..oldNick.." is now known as "..newNick)
        end
)
--[[
addEventHandler("onPlayerMute",root,
        function ()
                outputIRC("12* "..getNameNoColor(source).." has been muted")
        end
)

addEventHandler("onPlayerUnmute",root,
        function ()
                outputIRC("12* "..getNameNoColor(source).." has been unmuted")
        end
)
--]]




addEventHandler("onPlayerChat",root,
        function (message,type)
		if getElementData(source, "spam") == 1 then
			return 
		end
		if getResourceFromName('censorship') and getResourceState(getResourceFromName('censorship')) == 'running' and exports.censorship:isBlockedMsg(message) then return end
		message = string.gsub (message, '#%x%x%x%x%x%x', '' )
        if type == 0 then
			local accName = getAccountName ( getPlayerAccount ( source ) )
			if accName and aclGetGroup ( "Admin" ) and isObjectInACLGroup ("user."..accName, aclGetGroup ( "Admin" ) ) then
				outputIRC("12"..getNameNoColor(source)..": "..message)
			elseif accName and aclGetGroup ( "Killers" ) and isObjectInACLGroup ("user."..accName, aclGetGroup ( "Killers" ) ) then
				outputIRC("4"..getNameNoColor(source)..": "..message)
			elseif getElementData ( source, "adminapplicant" ) then
				outputIRC("13"..getNameNoColor(source)..": "..message)
			else
				outputIRC("07"..getNameNoColor(source)..": "..message)
			end
		elseif type == 1 then
			outputIRC("06* "..getNameNoColor(source).." "..message)
		elseif type == 2 then
			--outputIRC("07(TEAM)"..getNameNoColor(source)..": "..message)
	
		end
        end
)






local bodyparts = {nil,nil,"Torso","Ass","Left Arm","Right Arm","Left Leg","Right Leg","Head"}
local weapons = {}
weapons[19] = "Rockets"
weapons[88] = "Fire"
--[[addEventHandler("onPlayerWasted",root,
        function (ammo,killer,weapon,bodypart)
                if killer then
                        if getElementType(killer) == "vehicle" then
                                local driver = getVehicleController(killer)
                                if driver then
                                        outputIRC("04* "..getPlayerName(source).." was killed by "..getPlayerName(driver).." in a "..getVehicleName(killer))
                                else
                                        outputIRC("04* "..getPlayerName(source).." was killed by an "..getVehicleName(killer))
                                end
                        elseif getElementType(killer) == "player" then
                                if weapon == 37 then
                                        if getPedWeapon(killer) ~= 37 then
                                                weapon = 88
                                        end
                                end
                                outputIRC("04* "..getPlayerName(source).." was killed by "..getPlayerName(killer).." ("..(getWeaponNameFromID(weapon) or weapons[weapon] or "?")..")("..bodyparts[bodypart]..")")
                        else
                                outputIRC("04* "..getPlayerName(source).." died")
                        end
                else
                        outputIRC("04* "..getPlayerName(source).." died")
                end
        end
)]]
                
addEvent("onPlayerFinish",true)
addEventHandler("onPlayerFinish",root,
        function (rank,time)
                outputIRC("12* "..getNameNoColor(source).." finished (rank: "..rank.." time: "..msToTimeStr(time)..")")
        end
)

addEvent("onMapStarting")
addEventHandler("onMapStarting",root,
		function (mapinfo)
				outputIRC("12* Map started: "..mapinfo.name.. "12 / Gamemode: ".. mapinfo.modename)
		end
, true, 'high')

addEvent("onPlayerToptimeImprovement",true)
addEventHandler("onPlayerToptimeImprovement",root,
        function (newPos,newTime,oldPos,oldTime)
                if newPos == 1 then
                       outputIRC("07* New record: "..msToTimeStr(newTime).." by "..getNameNoColor(source).."!")
                end
        end
)

addEventHandler("onBan",root,
        function (ban)
                outputIRC("12* Ban added by "..(getPlayerName(source) or "Console")..": name: "..(getBanNick(ban) or "/")..", ip: "..(getBanIP(ban) or "/")..", serial: "..(getBanSerial(ban) or "/")..", banned by: "..(getBanAdmin(ban) or "/").." banned for: "..(getBanReason(ban) or "/"))
        end
)

addEventHandler("onUnban",root,
        function (ban)
                outputIRC("12* Ban removed by "..(getPlayerName(source) or "Console")..": name: "..(getBanNick(ban) or "/")..", ip: "..(getBanIP(ban) or "/")..", serial: "..(getBanSerial(ban) or "/")..", banned by: "..(getBanAdmin(ban) or "/").." banned for: "..(getBanReason(ban) or "/"))
        end
)

------------------------------------
-- Admin interaction
------------------------------------
addEvent("onPlayerFreeze")
addEventHandler("onPlayerFreeze",root,
        function (state)
               if state then
			outputIRC("12* "..getNameNoColor(source).." was frozen!")
		else
			outputIRC("12* "..getNameNoColor(source).." was unfrozen!")
		end
        end
)

addEvent("onPlayerMute")
addEventHandler("onPlayerMute",root,
        function (state)
               if state then
			--outputIRC("12* "..getNameNoColor(source).." was muted!")
		else
			--outputIRC("12* "..getNameNoColor(source).." was unmuted!")
		end
        end
)

------------------------------------
-- Votemanager interaction
------------------------------------
local pollTitle

addEvent("onPollStarting")
addEventHandler("onPollStarting",root,
        function (data)
                if data.title then
                        pollTitle = tostring(data.title)
                end
        end
)

addEvent("onPollModified")
addEventHandler("onPollModified",root,
        function (data)
                if data.title then
                        pollTitle = tostring(data.title)
                end
        end
)

addEvent("onPollStart")
addEventHandler("onPollStart",root,
        function ()
                if pollTitle then
                        outputIRC("14* A vote was started ["..tostring(pollTitle).."]")
                end
        end
)

addEvent("onPollStop")
addEventHandler("onPollStop",root,
        function ()
                if pollTitle then
                        pollTitle = nil
                        outputIRC("14* Vote stopped!")
                end
        end
)

addEvent("onPollEnd")
addEventHandler("onPollEnd",root,
        function ()
                if pollTitle then
                        pollTitle = nil
                        outputIRC("14* Vote ended!")
                end
        end
)

addEvent("onPollDraw")
addEventHandler("onPollDraw",root,
        function ()
                if pollTitle then
                        pollTitle = nil
                        outputIRC("14* A draw was reached!")
                end
        end
)

--------------------------------------------------------------------

addEvent("onIRCUserJoin")
addEventHandler("onIRCUserJoin",root,
	function (channel,vhost)
		if not ircIsEchoChannel(channel) then return end
		outputChatBox("* "..ircGetUserNick(source).." has joined IRC",root,255,168,0)
	end
)

addEvent("onIRCUserPart")
addEventHandler("onIRCUserPart",root,
	function(channel,reason)
		if not ircIsEchoChannel(channel) then return end
		outputChatBox("* "..ircGetUserNick(source).." has left IRC",root,255,168,0)
	end
)

addEvent("onIRCUserQuit")
addEventHandler("onIRCUserQuit",root,
	function (reason)
		outputChatBox("* "..ircGetUserNick(source).." has left IRC",root,255,168,0)
	end
)

addEvent("onIRCUserKick")
addEventHandler("onIRCUserKick",root,
	function(channel,reason,kicker)
		outputChatBox("* "..ircGetUserNick(source).." has been kicked from IRC (" .. reason .. ")",root,255,168,0)
	end
)

addEvent("onIRCUserChangeNick")
addEventHandler("onIRCUserChangeNick",root,
	function (oldnick,newnick)
		outputChatBox("* "..oldnick.." is now known as "..newnick.. " on IRC",root,255,168,0)
	end
)
