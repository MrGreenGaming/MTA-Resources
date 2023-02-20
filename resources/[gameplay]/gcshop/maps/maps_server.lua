local prices = {}
prices["race"] = 275
prices["rtf"] = 250
prices["ctf"] = 200
prices["nts"] = 275
prices["shooter"] = 500
prices["deadline"] = 175


local PRICE = 1000
local mp_maxBuyAmount = 3 -- Daily map buy amount
local mp_cooldownTime = 360*60 -- Minutes of cooldown for specific maps
local cm_cooldownTime = 60*60 -- Minutes of cooldown for coremarker maps
local mp_staffMapFree = false -- Is map free for staff in ACL below
local mp_staffACLNames = {
    'ServerManager',
    'mapmanager',
    'Developer'
}
----------------------
-- Winners discount --
----------------------

lastWinner = nil
lastWinnerDiscount = 50

-- Race, NTS, RTF
function finish( rank )
	if rank == 1 then
		setWinner(source)
	end
end
addEventHandler("onPlayerFinish", root, finish)

function shooterWin()
	setWinner(source)
end
addEvent('onPlayerWinShooter')
addEventHandler('onPlayerWinShooter', root, shooterWin)

function ddWin()
	setWinner(source)
end
addEvent('onPlayerWinDD')
addEventHandler('onPlayerWinDD', root, ddWin)

function dlWin(position, timePassed)
	setWinner(source)
end
addEventHandler('onPlayerWinDeadline', root, dlWin)

function setWinner(player)
	lastWinner = player
	triggerClientEvent('onGCShopWinnerDiscount', lastWinner)
	-- outputDebugString('Winner ' .. getPlayerName(lastWinner))
end

----------------------

function getServerMaps ()
	local tableOut = {}
	local gamemode = getResourceFromName("race")
        local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode" , gamemode)
        for _,map in ipairs (maps) do
			local name = getResourceInfo(map, "racemode") or "race"
			if (not tableOut[name]) then
				tableOut[name] = {}
				tableOut[name].name = name
				tableOut[name].resname = getResourceName(gamemode)
				tableOut[name].maps = {}
			end

            table.insert(tableOut[name]["maps"] ,{name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map), author = getResourceInfo ( map, "author" )})
        end

		for name, mode in pairs(tableOut) do
			table.sort(mode.maps, sortCompareFunction)
		end


    table.sort((tableOut), sortCompareFunction)

	triggerClientEvent(source ,"sendMapsToBuy", source, tableOut, myQueue)
end
addEvent('refreshServerMaps', true)
addEventHandler('refreshServerMaps', root, getServerMaps)

function sortCompareFunction(s1, s2)
	if type(s1) == "table" and type(s2) == "table" then
		s1, s2 = s1.name, s2.name
	end
    s1, s2 = s1:lower(), s2:lower()
    if s1 == s2 then
        return false
    end
    local byte1, byte2 = string.byte(s1:sub(1,1)), string.byte(s2:sub(1,1))
    if not byte1 then
        return true
    elseif not byte2 then
        return false
    elseif byte1 < byte2 then
        return true
    elseif byte1 == byte2 then
        return sortCompareFunction(s1:sub(2), s2:sub(2))
    else
        return false
    end
end

local function isPlayerStaff(player)
    if not mp_staffMapFree then return false end
    local accountName = getAccountName( getPlayerAccount(player) )
    if accountName ~= "guest" then
        local isInAcl = false
        for _, name in ipairs(mp_staffACLNames) do
            if isObjectInACLGroup( "user."..accountName, aclGetGroup(name) ) then
                isInAcl = true
                break
            end
        end
        return isInAcl
    end
    return false
end

addEvent('sendPlayerNextmapChoice', true)
addEventHandler('sendPlayerNextmapChoice', root,
function(choice)
    local isFreeMap = isPlayerStaff(source)
    if not isFreeMap and isDailyLimitReached(tostring(choice[2])) then return end -- Check for map bought amount if not admin
	local racemode = getResourceInfo(getResourceFromName(choice[2]), "racemode") or "race"
    local isCoremarkers = isCoremarkersMap(choice[2])

    outputDebugString("Is bought map coremarkers? " .. tostring(isCoremarkers))

    if isPlayerEligibleToBuy(source, choice) then
        if playerHasBoughtMap(source, choice) then
            queue(choice, source)
        else
			local mapprice = source == lastWinner and (getGamemodePrice(racemode) / 100) * (100 - lastWinnerDiscount) or getGamemodePrice(racemode)
            local vipIsRunning = getResourceState( getResourceFromName( "mrgreen-vip" ) ) == "running"
			if vipIsRunning and exports['mrgreen-vip']:isPlayerVIP(source) then
				mapprice = (mapprice / 100) * 90
            end
            mapprice = math.round(mapprice)

            if vipIsRunning and exports['mrgreen-vip']:canBuyVipMap(source) then
                mapprice = 0
            end
            outputChatBox("[Maps-Center] You do not have enough GCs to buy a nextmap. Current price: "..tostring(mapprice), source, 255, 0, 0)
        end
    else
        outputChatBox("[Maps-Center] Error. You can only queue one map, you're not logged in or map was deleted", source, 255, 0, 0)
    end
end)

function getGamemodePrice(gamemode)
	return prices[gamemode] or PRICE
end

function isCoremarkersMap(mapResourceName)
    local meta = xmlLoadFile(':'.. mapResourceName..'/meta.xml', true)

    local children = xmlNodeGetChildren(meta)
    for _, child in ipairs(children) do
        if xmlNodeGetName(child) == 'include' then
            local includedResource = xmlNodeGetAttribute(child, 'resource')
            if includedResource == 'coremarkers' then
                return true
            end
        end
    end
    return false
end

function isDailyLimitReached(mapname)
    -- Check if element data exists first
    local theAmountTable = getElementData(root,"dailyMapBuyAmount")
    if type(theAmountTable) ~= "table"  then
        local t = {day = getRealTime().yearday}
        setElementData(root,"dailyMapBuyAmount",t)
        theAmountTable = t
    elseif theAmountTable.day ~= getRealTime().yearday then
        local t = {day = getRealTime().yearday}
        setElementData(root,"dailyMapBuyAmount",t)
        theAmountTable = t
    end

    -- Check daily limit
    if theAmountTable[mapname] then
        -- if theAmountTable[mapname].times > mp_maxBuyAmount then
        --     outputChatBox("[Maps-Center] Daily Buy limit ("..tostring(mp_maxBuyAmount).." times) for this map has been reached, please buy another map", source, 255, 0, 0)
        --     return true
        if ( getRealTime().timestamp-theAmountTable[mapname].timestamp ) < mp_cooldownTime then
            local timeLeft = mp_cooldownTime - (getRealTime().timestamp - theAmountTable[mapname].timestamp)
            local timeLeft = secondsToTimeDesc(math.ceil(timeLeft))--math.ceil(minsleft/60)
            outputChatBox("[Maps-Center] This map has recently been bought and is still on cooldown ("..tostring(timeLeft).." remaining), please choose another map or wait.", source, 255, 0, 0)

            return true
        end
        return false
    else
        return false
    end
end



function addDailyLimit(mapname,player)
    -- Check if element data exists first

    if not mapname then return end
    local theAmountTable = getElementData(root,"dailyMapBuyAmount")
    if type(theAmountTable) ~= "table"  then
        local t = {day = getRealTime().yearday}
        setElementData(root,"dailyMapBuyAmount",t)
        theAmountTable = t
    elseif theAmountTable.day ~= getRealTime().yearday then
        local t = {day = getRealTime().yearday}
        setElementData(root,"dailyMapBuyAmount",t)
        theAmountTable = t
    end
    -- add Daily limit
    if theAmountTable[mapname] then
        -- theAmountTable[mapname].times = theAmountTable[mapname].times + 1
        theAmountTable[mapname].timestamp = getRealTime().timestamp
    else
        theAmountTable[mapname] = {}
        -- theAmountTable[mapname].times = 1
        theAmountTable[mapname].timestamp = getRealTime().timestamp
    end
    if player then
        local mpn = getResourceInfo(getResourceFromName(mapname),"name") or mapname
        --outputChatBox("[Maps-Center] "..mpn.." has been bought "..tostring(theAmountTable[mapname].times).." time(s) today", player, 0, 255, 0)
    end

    setElementData(root,"dailyMapBuyAmount",theAmountTable)

end

function queue(choice, player)
	choice.forumID = exports.gc:getPlayerForumID(player)
    table.insert(myQueue, choice)
    outputChatBox("[Maps-Center] "..getPlayerName(player):gsub( '#%x%x%x%x%x%x', '' ).." has queued the map \"".. choice[1] .."\"! Queued position: " .. #myQueue .. "!", root, 0, 255, 0)
    if getResourceState( getResourceFromName('irc') ) == 'running' then
        exports.irc:outputIRC("12*** Map queued by " .. getPlayerName(source):gsub( '#%x%x%x%x%x%x', '' ) .. ": 1" .. choice[1] )
    end
    triggerClientEvent('onTellClientPlayerBoughtMap', player, choice[1], #myQueue)
    triggerEvent('onNextmapSettingChange', root, getResourceFromName(myQueue[1][2]))
	addToLog ( '"' .. getPlayerName(player) .. '" bought map=' .. tostring(choice[1]))
    addDailyLimit(tostring(choice[2]),player)
end

function getCurrentMapQueued(noRemove)
    if #myQueue == 0 then
        return false
    end
    if not getResourceFromName(myQueue[1][2]) then
        outputChatBox("[Maps-Center] ERROR: QUEUED MAP MAY HAVE BEEN DELETED BEFORE IT WAS PLAYED. CONTACT ADMIN FOR REFUND.", root, 255, 0, 0)
        return false
    end
    local choice = myQueue[1]
    if not noRemove then
        table.remove(myQueue, 1)
        if #myQueue > 0 then
            triggerEvent('onNextmapSettingChange', root, getResourceFromName(myQueue[1][2]))
        end
    end
    return choice
end



function isAnyMapQueued()
    if #myQueue > 0 then
        return true
    end
    return false
end

function isPlayerEligibleToBuy(player, choice)
	local gcRes = getResourceFromName('gc')
	if gcRes and getResourceState(gcRes) == 'running' and exports.gc then
		if not exports.gc:isPlayerLoggedInGC(player) then return false end
		if not getResourceFromName(choice[2]) then return false end
		for _, c in ipairs(myQueue) do
			if c.forumID == exports.gc:getPlayerForumID(player) then return false end
		end
		return true
	else
		return false
	end
end

function playerHasBoughtMap(player, choice)
    if (isPlayerStaff(player)) then  -- Free for acl objects specified in isPlayerStaff
		return true
	end
	local racemode = getResourceInfo(getResourceFromName(choice[2]), "racemode") or "race"
	local mapprice = player == lastWinner and (getGamemodePrice(racemode) / 100) * (100 - lastWinnerDiscount) or getGamemodePrice(racemode) --if the player is the last winner it gives them the price discounted by 'lastWinnerDiscount' percent, if not it takes the regular price
	local vipIsRunning = getResourceState( getResourceFromName( "mrgreen-vip" ) ) == "running"
    if exports["mrgreen-vip"]:isPlayerVIP(player) then
		mapprice = (mapprice / 100) * 90 -- 10% off if he is vip
	end
    local isVipBuy = false
    if vipIsRunning and exports['mrgreen-vip']:canBuyVipMap(source) then
        isVipBuy = true
        mapprice = 0
    end

    mapprice = math.round(mapprice)

	local money = exports.gc:getPlayerGreencoins(player)
    if not isVipBuy and money < mapprice then return false end

	local ok = gcshopBuyItem ( player, mapprice, 'Map: ' .. choice[1])
    if isVipBuy and ok then
        exports['mrgreen-vip']:playerUsedFreeVipMap(source)
    end
    return ok
end

myQueue = {}
addEventHandler('onResourceStart', getResourceRootElement(),
    function()
        myQueue = {}
        isDailyLimitReached(false)
    end)

function var_dump(...)
    -- default options
    local verbose = false
    local firstLevel = true
    local outputDirectly = true
    local noNames = false
    local indentation = "\t\t\t\t\t\t"
    local depth = nil

    local name = nil
    local output = {}
    for k,v in ipairs(arg) do
        -- check for modifiers
        if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
            local modifiers = v:sub(2)
            if modifiers:find("v") ~= nil then
                verbose = true
            end
            if modifiers:find("s") ~= nil then
                outputDirectly = false
            end
            if modifiers:find("n") ~= nil then
                verbose = false
            end
            if modifiers:find("u") ~= nil then
                noNames = true
            end
            local s,e = modifiers:find("d%d+")
            if s ~= nil then
                depth = tonumber(string.sub(modifiers,s+1,e))
            end
        -- set name if appropriate
        elseif type(v) == "string" and k < #arg and name == nil and not noNames then
            name = v
        else
            if name ~= nil then
                name = ""..name..": "
            else
                name = ""
            end

            local o = ""
            if type(v) == "string" then
                table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
            elseif type(v) == "userdata" then
                local elementType = "no valid MTA element"
                if isElement(v) then
                    elementType = getElementType(v)
                end
                table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
            elseif type(v) == "table" then
                local count = 0
                for key,value in pairs(v) do
                    count = count + 1
                end
                table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
                if verbose and count > 0 and (depth == nil or depth > 0) then
                    table.insert(output,"\t{")
                    for key,value in pairs(v) do
                        -- calls itself, so be careful when you change anything
                        local newModifiers = "-s"
                        if depth == nil then
                            newModifiers = "-sv"
                        elseif  depth > 1 then
                            local newDepth = depth - 1
                            newModifiers = "-svd"..newDepth
                        end
                        local keyString, keyTable = var_dump(newModifiers,key)
                        local valueString, valueTable = var_dump(newModifiers,value)

                        if #keyTable == 1 and #valueTable == 1 then
                            table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
                        elseif #keyTable == 1 then
                            table.insert(output,indentation.."["..keyString.."]\t=>")
                            for k,v in ipairs(valueTable) do
                                table.insert(output,indentation..v)
                            end
                        elseif #valueTable == 1 then
                            for k,v in ipairs(keyTable) do
                                if k == 1 then
                                    table.insert(output,indentation.."["..v)
                                elseif k == #keyTable then
                                    table.insert(output,indentation..v.."]")
                                else
                                    table.insert(output,indentation..v)
                                end
                            end
                            table.insert(output,indentation.."\t=>\t"..valueString)
                        else
                            for k,v in ipairs(keyTable) do
                                if k == 1 then
                                    table.insert(output,indentation.."["..v)
                                elseif k == #keyTable then
                                    table.insert(output,indentation..v.."]")
                                else
                                    table.insert(output,indentation..v)
                                end
                            end
                            for k,v in ipairs(valueTable) do
                                if k == 1 then
                                    table.insert(output,indentation.." => "..v)
                                else
                                    table.insert(output,indentation..v)
                                end
                            end
                        end
                    end
                    table.insert(output,"\t}")
                end
            else
                table.insert(output,name..type(v).." \""..tostring(v).."\"")
            end
            name = nil
        end
    end
    local string = ""
    for k,v in ipairs(output) do
        if outputDirectly then
            outputConsole(v)
        end
        string = string..v
    end
    return string, output
end

-- misc
function secondsToTimeDesc( seconds )
    if seconds then
        local results = {}
        local sec = ( seconds %60 )
        local min = math.floor ( ( seconds % 3600 ) /60 )
        local hou = math.floor ( ( seconds % 86400 ) /3600 )
        local day = math.floor ( seconds /86400 )

        if day > 0 then table.insert( results, day .. ( day == 1 and " day" or " days" ) ) end
        if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
        if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
        if sec > 0 then table.insert( results, sec .. ( sec == 1 and " second" or " seconds" ) ) end

        return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
    end
    return ""
end

function mapstop100_insert(p, maps100)
	for _,map in ipairs(myQueue) do
		local str = string.find(tostring(map[4]), "Mr. Green maps top 100")
		if str then
			outputChatBox("ERROR: Mr. Green maps top 100 already running.",p)
			return
		end
	end

	local serverMaps = {}
	local gamemode = getResourceFromName("race")
    local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode" , gamemode)
    for _,map in ipairs (maps) do
        table.insert(serverMaps, {name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map), author = getResourceInfo ( map, "author" )})
    end

	for _,row in ipairs(maps100) do
		for i,v in ipairs(serverMaps) do
			if tostring(row.mapresourcename) == v.resname then
				local maps100_name = "Mr. Green maps top 100 - number " .. row.rank .. "!"
				local choice = {v.name, v.resname, getResourceName(gamemode), maps100_name}
				choice.forumID = 19
				table.insert(myQueue, choice)
			end
		end
	end

	triggerClientEvent(p,"mapstop100_refresh",resourceRoot)

	local tableOut = {}
	local gamemode = getResourceFromName("race")
        local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode" , gamemode)
        for _,map in ipairs (maps) do
			local name = getResourceInfo(map, "racemode") or "race"
			if (not tableOut[name]) then
				tableOut[name] = {}
				tableOut[name].name = name
				tableOut[name].resname = getResourceName(gamemode)
				tableOut[name].maps = {}
			end

            table.insert(tableOut[name]["maps"] ,{name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map), author = getResourceInfo ( map, "author" )})
        end

		for name, mode in pairs(tableOut) do
			table.sort(mode.maps, sortCompareFunction)
		end


    table.sort((tableOut), sortCompareFunction)

	triggerClientEvent(p ,"sendMapsToBuy", p, tableOut, myQueue)
end
addEvent("mapstop100_insert", true)
addEventHandler("mapstop100_insert", resourceRoot, mapstop100_insert)

function mapstop100_remove(p)
	for _,map in ipairs(myQueue) do
		local str = string.find(tostring(map[4]), "Mr. Green maps top 100")
		if str then
			--table.remove(myQueue, _)
			myQueue[_] = nil
		end
	end

	triggerClientEvent(p,"mapstop100_refresh",resourceRoot)

	local tableOut = {}
	local gamemode = getResourceFromName("race")
        local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode" , gamemode)
        for _,map in ipairs (maps) do
			local name = getResourceInfo(map, "racemode") or "race"
			if (not tableOut[name]) then
				tableOut[name] = {}
				tableOut[name].name = name
				tableOut[name].resname = getResourceName(gamemode)
				tableOut[name].maps = {}
			end

            table.insert(tableOut[name]["maps"] ,{name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map), author = getResourceInfo ( map, "author" )})
        end

		for name, mode in pairs(tableOut) do
			table.sort(mode.maps, sortCompareFunction)
		end


    table.sort((tableOut), sortCompareFunction)

	triggerClientEvent(p ,"sendMapsToBuy", p, tableOut, myQueue)

	outputChatBox("All maps removed from map queue.",p)
end
addEvent("mapstop100_remove", true)
addEventHandler("mapstop100_remove", resourceRoot, mapstop100_remove)
