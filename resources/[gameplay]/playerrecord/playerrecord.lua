local peak = 0
local timeToReset = false

--Command
function command(player)
	local reset = ""
	local rTime = timeToReset - getTimestamp()

	if rTime < 86400 then	--If the record is gonna reset in less than a day
		local hours = math.floor(rTime / 60 / 60)
		local minutes = math.floor((rTime - (hours * 60 * 60)) / 60)
        outputChatBox(_.For(player, "The current player record is ${peak} players and it's going to reset in ${hours} days and ${minutes} minutes") % {peak=peak, hours=hours, minutes=minutes}, player, 0, 255, 0)
	else
		local days = math.floor(rTime / 86400)
		local hours = math.floor((rTime - (days * 86400)) / 60 / 60)
        outputChatBox(_.For(player, "The current player record is ${peak} players and it's going to reset in ${days} days and ${hours} hours") % {peak=peak, days=days, hours=hours}, player, 0, 255, 0)
	end
end
addCommandHandler("currentrecord", command)



function playerJoin()
	local current = getPlayerCount()
	if tonumber(current) > tonumber(peak) then
        -- New record, give everyone points

        for i,p in ipairs(getElementsByType("player")) do
            outputChatBox(_.For(p, "We got a new player record of ${playerAmount} players! Giving everyone ${gcAmount} GCs!") % {playerAmount=current, gcAmount=get("greencoinsamount")}, p, 0, 255, 0)
			exports.gc:addPlayerGreencoins(p, tonumber(get("greencoinsamount")))
		end
		peak = current
		local file = xmlCreateFile("peak.xml", "peak")
		local node = xmlCreateChild(file, "currentRecord", 0)
		xmlNodeSetValue(node, tonumber(peak))
		local attr = getTime()
		xmlNodeSetAttribute(node, "time", attr)
		timeToReset = getTimestampFromDateString(attr) + tonumber(get("resettime"))
		local s = xmlSaveFile(file)
		if not s then
			outputDebugString("[Player record] Unable to save file!")
		end

	end
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function startResource()
	outputDebugString("[Player record] Starting resource...")
	local file = xmlLoadFile("peak.xml")
	if not file then
		outputDebugString("[Player record] File not found, creating...")
		file = xmlCreateFile("peak.xml", "peak")
		local node = xmlCreateChild(file, "currentRecord")
		local attr = getTime()
		xmlNodeSetAttribute(node, "time", attr)
		xmlNodeSetValue(node, 0)
		xmlSaveFile(file)
	end
	local node = xmlFindChild(file, "currentRecord", 0)
	peak = xmlNodeGetValue(node)

	outputDebugString("[Player record] Current peak: " .. peak)

	timeToReset = getTimestampFromDateString(xmlNodeGetAttribute(node, "time")) + tonumber(get("resettime"))

	setTimer(Timer, 1000, 0)
end
addEventHandler("onResourceStart", getResourceRootElement(), startResource)

function getTime()
	local t = getRealTime()
	local datetime = string.format("%04d-%02d-%02d %02d:%02d:%02d", t.year + 1900, t.month + 1, t.monthday, t.hour, t.minute, t.second)
	return datetime
end

function getTimestampFromDateString(timeString)
	local timeFormat = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
	local year, month, day, hour, minute, second = timeString:match(timeFormat)
	local timestamp = getTimestamp(tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute), tonumber(second))

	return timestamp
end

function Timer()
	if getTimestamp() >= timeToReset then
		outputDebugString("[Player record] Resetting record...")
		-- Reset the record
		local days = tonumber(get("resettime")) / 60 / 60 / 24

		local current = getPlayerCount()
		local gcs = tonumber(get("greencoinsamount")) * current
        outputDebugString("[Player record] Giving all players gcs!")

        for i,p in ipairs(getElementsByType("player")) do
            outputChatBox(_.For(p, "${days} days have passed since the last player record! Resetting the record and giving everyone ${reward} GCs!") % {days=days, reward=gcs}, p, 0, 255, 0)
			exports.gc:addPlayerGreencoins(p, gcs)
		end
		peak = current
		local file = xmlCreateFile("peak.xml", "peak")
		local node = xmlCreateChild(file, "currentRecord", 0)
		xmlNodeSetValue(node, tonumber(peak))
		local attr = getTime()
		xmlNodeSetAttribute(node, "time", attr)
		timeToReset = getTimestampFromDateString(attr) + tonumber(get("resettime"))
		local s = xmlSaveFile(file)
		if not s then
			outputDebugString("[Player record] Unable to save file!")
		end
	end
end

--https://wiki.multitheftauto.com/wiki/GetTimestamp
function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second

    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second

    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end

    return timestamp
end

--https://wiki.multitheftauto.com/wiki/IsLeapYear
function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

