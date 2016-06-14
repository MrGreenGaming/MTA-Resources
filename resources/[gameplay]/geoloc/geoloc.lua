local cache = {}		--	{ [IP] = {cc = "countryCode", country = "countryName"}, ... }

-- checks cache for loc data, request via api if not available
-- sets element data asap
function checkIP(player)
	if player and isElement(player) then
		local IP = getPlayerIP(player)
	    if cache[IP] then
			-- force resync by removing
	        removeElementData ( player, "country" )
	        removeElementData ( player, "fullCountryName" )
			setElementData(player, 'country', cache[IP].cc)
			setElementData(player, 'fullCountryName', cache[IP].country)
		elseif split(IP,'.')[1] == "192" or split(IP,'.')[1] == "172" or split(IP,'.')[1] == "10" or split(IP,'.')[1] == "127" then
			-- fetch our own IP for local adresses
			fetchRemote('http://www.geoplugin.net/json.gp', receiveIPdata, '', false, IP, getPlayerName(player))
		else
			fetchRemote('http://www.geoplugin.net/json.gp?ip=' .. IP, receiveIPdata, '', false, IP, getPlayerName(player))	
		end
-- 	else ignore
	end
end

function fetchip(p, cmd, IP)
	if #split(IP,'.') == 4 then
		fetchRemote('http://www.geoplugin.net/json.gp?ip=' .. IP, receiveIPdata, '', false, IP, '')
		--if p then
			outputChatBox( "Fetching geoloc for " .. IP , p)
		--end
	end
end
--addCommandHandler( "geoloc_fetchip", fetchip, true)

function receiveIPdata(json, err, IP, nick)
	-- check for fetchRemote errors
	if err ~= 0 then
		outputDebugString( "geoloc: receiveIPdata fetch failed, err=" .. tostring(err) .. ', json=' .. tostring(json) .. ', IP=' .. tostring(IP) .. ', nick=' .. tostring(nick))
		return
	end

	--check for parsing errors
	local table = fromJSON('['..json..']')
	if not (type(table) == 'table' and type(table.geoplugin_countryCode) == 'string' and #table.geoplugin_countryCode > 0) then
		outputDebugString( "geoloc: receiveIPdata parse failed, err=" .. tostring(err) .. ', json=' .. tostring(json) .. ', IP=' .. tostring(IP) .. ', nick=' .. tostring(nick))
		return
	end

	-- store data in cache
	cache[IP] = {cc = table.geoplugin_countryCode, country = table.geoplugin_countryName}

	-- if player is online (connecting or online), set element data
	local player = getPlayerFromName( nick )
	if player then
		setElementData(player, 'country', table.geoplugin_countryCode)
		setElementData(player, 'fullCountryName', table.geoplugin_countryName)
	end	
end

-- fetchip(nil,nil, "89.114.155.108")
-- fetchip(nil,nil, "186.63.9.151")
-- fetchip(nil,nil, "190.3.130.118")
-- fetchip(nil,nil, "190.195.104.235")
-- fetchip(nil,nil, "179.99.126.177")
-- fetchip(nil,nil, "201.22.14.45")

-- events
addEventHandler("onPlayerConnect", root, function(name)
	checkIP ( getPlayerFromName(name) )
end)

addEventHandler("onPlayerJoin", root, function()
	checkIP( source )
end, true, 'high+4')	-- high priority to make sure we set country data before other scripts access it

addEventHandler("onResourceStart", root,
    function(res)
        if res == resource or getResourceName(res) == "scoreboard" then
            exports.scoreboard:scoreboardAddColumn("country", root, 56, "Country", 20)
            for k, player in ipairs(getElementsByType"player") do
            	checkIP(player)
            end
        end
    end
)

addEventHandler("onResourceStop", getResourceRootElement(getThisResource()),
    function()
        for k, player in ipairs(getElementsByType"player")do
            removeElementData ( player, "country" )
            removeElementData ( player, "fullCountryName" )
        end
        exports.scoreboard:removeScoreboardColumn("country")
    end
)

-- exports
function getIPCountryCode ( IP )
	return cache[IP] and cache[IP].cc or false
end

function getIPCountryName ( IP )
	return cache[IP] and cache[IP].country or false
end

function getPlayerCountry ( player )
	return player and isElement(player) and getIPCountryCode(getPlayerIP(player)) or false
end

function getPlayerCountryName ( player )
	return player and isElement(player) and getIPCountryName(getPlayerIP(player)) or false
end

function getCache()
	return cache
end

-- /country
function findPlayerByName(playerPart)
	local pl = getPlayerFromName(playerPart)
	if isElement(pl) then
		return pl
	else
		for i,v in ipairs (getElementsByType ("player")) do
			if (string.find(string.gsub ( string.lower(getPlayerName(v)), '#%x%x%x%x%x%x', '' ),string.lower(playerPart))) then
				return v
			end
		end
    end
end

addCommandHandler('country',
function(player, command, arg)
	if not arg then outputChatBox('/country <partial name>', player) return end
	arg = findPlayerByName(arg)
	if arg then
		outputChatBox(string.gsub(getPlayerName(arg), '#%x%x%x%x%x%x', '' ).."'s country is: ".. (getElementData(arg, 'fullCountryName') or "Unknown"), player, 0, 255, 0)
	else
		outputChatBox('Player inexistent', player)
	end
end
)

addCommandHandler('geoloc',function(player, command, arg)
	local ips = 0
	local countries, ID = {}, {}	-- ID is a temp linking table to increase the counters before sorting
	for IP, c in pairs(cache) do
		ips = ips + 1
		if not ID[c.country] then
			table.insert(countries, {count = 1 , name = c.country})
			ID[c.country] = #countries
		else
			countries[ID[c.country]].count = countries[ID[c.country]].count + 1
		end
	end
	table.sort(countries, function(a,b) return a.count > b.count end)
	outputChatBox('Geoloc cache IP\'s=' .. ips .. ', countries=' .. #countries, player)
	for id=1,7 do
		if countries[id] then
			outputChatBox( '#' .. id .. ': ' .. countries[id].name .. "(" .. countries[id].count .. ')', player)
		else
			return
		end
	end
end)
