
function string:monochrome()
    local colorless = self:gsub("#%x%x%x%x%x%x", "")

    if colorless == "" then
        return self:gsub("#(%x%x%x%x%x%x)", "#\1%1")
    else
        return colorless
    end
end

function getPlayerName(player)
    return player.name:monochrome()
end


function sendPlayerCount(correction)
    serverType = get("server")
    correction = correction or 0
    local player_count = getPlayerCount() + correction
    local max_players = getMaxPlayers()
    if (serverType == "race") then
        exports.discord:send("server.player_count_race", { player_count = player_count, max_players = max_players })
    elseif (serverType == "mix") then
        exports.discord:send("server.player_count_mix", { player_count = player_count, max_players = max_players })
    end

end
addEventHandler("onDiscordChannelBound", root, sendPlayerCount)

addEvent("onDiscordUserCommand")

addEventHandler("onPlayerJoin", root,
    function ()
        exports.discord:send("player.join", { player = getPlayerName(source) })
        sendPlayerCount()
    end
)

addEventHandler("onPlayerQuit", root,
    function (quitType, reason, responsible)
        local playerName = getPlayerName(source)

        if isElement(responsible) then
            if getElementType(responsible) == "player" then
                responsible = getPlayerName(responsible)
            else
                responsible = "Console"
            end
        else
            responsible = false
        end

        if type(reason) ~= "string" or reason == "" then
            reason = false
        end

        if quitType == "Kicked" and responsible then
            exports.discord:send("player.kick", { player = playerName, responsible = responsible, reason = reason })
        elseif quitType == "Banned" and responsible then
            exports.discord:send("player.ban", { player = playerName, responsible = responsible, reason = reason })
        else
            exports.discord:send("player.quit", { player = playerName, type = quitType, reason = reason })
        end
        sendPlayerCount(-1)
    end
)

addEventHandler("onPlayerChangeNick", root,
    function (previous, nick)
        exports.discord:send("player.nickchange", { player = nick:monochrome(), previous = previous:monochrome() })
    end
, true, "low")

addEventHandler("onPlayerChat", root,
    function (message, messageType)
		if getResourceFromName('censorship') and getResourceState(getResourceFromName('censorship')) == 'running' and exports.censorship:isBlockedMsg(message) then return end
        if messageType == 0 then
            exports.discord:send("chat.message.text", { author = getPlayerName(source), text = message })
        end
    end
)

addEvent("onInterchatMessage")
addEventHandler("onInterchatMessage", root,
    function (server, playerName, message)
        exports.discord:send("chat.message.interchat", { author = playerName:monochrome(), server = server, text = message })
    end
)

local mutes = {}
local lastchatid, lastchatnick

function onStart()
    mutes = {}
    local xml = xmlLoadFile("mutes.xml")
    if xml then
        local nodes = xmlNodeGetChildren(xml)
        for _, node in ipairs(nodes) do
            local id = xmlNodeGetAttribute(node, "id")
            local by = xmlNodeGetAttribute(node, "by")
            mutes[id] = by
        end
        xmlUnloadFile(xml)
    else
        xml = xmlCreateFile("mutes.xml", "mutes")
        xmlSaveFile(xml)
        xmlUnloadFile(xml)
    end
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function saveMutesToXML()
    local xml = xmlLoadFile("mutes.xml") or xmlCreateFile("mutes.xml", "mutes")

    -- Clear existing nodes in the XML
    local childNodes = xmlNodeGetChildren(xml)
    for _, childNode in ipairs(childNodes) do
        xmlDestroyNode(childNode)
    end

    -- Create new nodes for each mute entry
    for id, by in pairs(mutes) do
        local node = xmlCreateChild(xml, "mute")
        xmlNodeSetAttribute(node, "id", id)
        xmlNodeSetAttribute(node, "by", by)
    end

    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

function removeMuteFromXML(id)
    local xml = xmlLoadFile("mutes.xml")
    if xml then
        local nodes = xmlNodeGetChildren(xml)
        for _, node in ipairs(nodes) do
            local xmlId = xmlNodeGetAttribute(node, "id")
            if xmlId == id then
                xmlDestroyNode(node)
                break
            end
        end
        xmlSaveFile(xml)
        xmlUnloadFile(xml)
    end
end

function discordmutelast(p, c)
    local isConsole = getElementType(p) == "console"
    local playerName = isConsole and "Console" or getPlayerName(p)
    if not hasObjectPermissionTo(p, 'command.mute') then
        outputDebugString('no access to discord command')
        return
    end
    if not lastchatid then
        outputChatBox('No last discord chatter', p, 255, 0, 0)
    else
        outputChatBox('Discord user ' .. lastchatnick .. ' muted by ' .. playerName, root, 255, 0, 0)
        mutes[lastchatid] = playerName
        saveMutesToXML()  -- Save to mutes.xml
    end
end
addCommandHandler('discordmutelast', discordmutelast)

function discordmuteid(p, c, id)
    local isConsole = getElementType(p) == "console"
    local playerName = isConsole and "Console" or getPlayerName(p)
    if not hasObjectPermissionTo(p, 'command.mute') then
        outputDebugString('no access to discord command')
        return
    end
    if not id then
        outputChatBox('usage: /discordmuteid <discordid>', p, 255, 0, 0)
    else
        outputChatBox('Discord user ' .. id .. ' muted by ' .. playerName, root, 255, 0, 0)
        mutes[id] = playerName
        saveMutesToXML()  -- Save to mutes.xml
    end
end
addCommandHandler('discordmuteid', discordmuteid)

function discordunmuteid(p, c, id)
    local isConsole = getElementType(p) == "console"
    local playerName = isConsole and "Console" or getPlayerName(p)
    if not hasObjectPermissionTo(p, 'command.mute') then
        outputDebugString('no access to discord command')
        return
    end
    if not id then
        outputChatBox('usage: /discordunmuteid <discordid>', p, 255, 0, 0)
    else
        outputChatBox('Discord user ' .. id .. ' unmuted by ' .. playerName, root, 255, 0, 0)
        mutes[id] = nil
        removeMuteFromXML(id)  -- Remove from mutes.xml
    end
end
addCommandHandler('discordunmuteid', discordunmuteid)

function discordmutes(p, c)
    outputChatBox('Discord mutes: ', p, 255, 0, 0)
    for id, by in pairs(mutes) do
        outputChatBox('Discord user ' .. id .. ' muted by ' .. by, p, 255, 0, 0)
    end
end
addCommandHandler('discordmutes', discordmutes)


addEvent("onDiscordPacket")
addEventHandler("onDiscordPacket", root,
    function (packet, payload)
		if mutes[payload.author.id] then exports.discord:send("chat.message.action", { author = ">", text = "<@" .. payload.author.id .. ">. You are muted and can't communicate with this bot"})return end
        if packet == "text.message" then
			lastchatid, lastchatnick = tostring(payload.author.id), payload.author.name
            outputServerLog(("DISCORD: %s: %s"):format(payload.author.name, payload.message.text))
            outputChatBox(("#69BFDB[Đ] #FFFFFF%s: #E7D9B0%s"):format(payload.author.name, payload.message.text), root, 255, 255, 255, true)
            exports.discord:send("chat.confirm.message", { author = payload.author.name, message = payload.message })
	     exports.irc:outputIRC(("7* [DISCORD] %s: %s"):format(payload.author.name, payload.message.text))
        elseif packet == "text.command" then
            triggerEvent("onDiscordUserCommand", resourceRoot, payload.author, payload.message)
        end
    end
)

addEventHandler("onPlayerMute", root,
    function (state)
        if state == nil then
            return
        end

        if state then
            exports.discord:send("player.mute", { player = getPlayerName(source) })
        else
            exports.discord:send("player.unmute", { player = getPlayerName(source) })
        end
    end
)

addEvent("onGamemodeMapStart")
addEventHandler("onGamemodeMapStart", root,
    function (map)
        local name = map:getInfo("name") or map.name
        exports.discord:send("mapmanager.mapstart", { name = name })
    end
)

addEvent("onPlayerFinish")
addEventHandler("onPlayerFinish", root,
    function (rank, time)
        if rank > 3 then
            return
        end

        exports.discord:send("player.finish", { player = getPlayerName(source), rank = rank })
    end
)

addEvent("onPlayerToptimeImprovement")
addEventHandler("onPlayerToptimeImprovement", root,
	function (newPos, newTime, oldPos, oldTime, displayTopCount, entryCount)
        -- Do not show every achieved toptime
        if newPos > displayTopCount then
            return
        end

        -- We only handle race_toptimes
		if (not sourceResource or sourceResource ~= getResourceFromName("race_toptimes")) then
			return
		end

        local time = ("%02d:%02d:%03d"):format(math.floor(newTime / 60000), math.floor(newTime / 1000) % 60, newTime % 1000)
        exports.discord:send("player.toptime", { player = getPlayerName(source), position = newPos, time = time })
    end
)
