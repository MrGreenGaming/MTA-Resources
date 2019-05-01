local mostMonthlyReward = 20		-- GC for having the most monthly tops in a month
local monthlyReward = 5				-- GC for having a monthly top
local baseTop1Reward = 5			-- Base top1 reward, multiplied with amount of months on server
local displayTopCount = 10

local times = {}					-- [top] = {forumid=forumid,mapname=mapname, value=value, date=getRealTime().timestamp, formatDate = FormatDate(getRealTime().timestamp), player=player, mta_name=getPlayerName(player), new=true}
local monthtimes = {}
local monthtTopTime = nil
local mapname
local info
local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local racemodes = {
					["Sprint"] = "race",
					["Never the same"] = "nts",
					["Destruction derby"] = "dd",
					["Shooter"] = "sh",
					["Deadline"] = "dl",
					["Reach the flag"] = "rtf",
					--["Capture the flag"] = "ctf",
}

local country_sql_table = [[CREATE TABLE IF NOT EXISTS `country` (
	`forumid` INT(11) NOT NULL,
	`country` CHAR(2) NOT NULL,
	PRIMARY KEY (`forumid`),
	UNIQUE INDEX `forumid` (`forumid`)
)
]]

score = {}
score['Destruction derby'] = true
score['Shooter'] = true
score['Deadline'] = true


addEvent('onMapStarting')
addEventHandler('onMapStarting', root,
	function(mapInfo, mapOptions, gameOptions)
		if mapname then
			updatePosColumn(mapname)
		end
		queryMapTimes(mapInfo)
		checkResources()
	end
)

addEventHandler('onResourceStart', resourceRoot,
	function()
		handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"), "multi_statements=1")
		local raceInfo = getRaceInfo()
		if not handlerConnect then
			outputDebugString('Serial/IP Database error: could not connect to the mysql db')
			return
		elseif raceInfo then
			queryMapTimes(raceInfo.mapInfo, true)
		end
		checkResources()
		
		dbExec ( handlerConnect, country_sql_table )
	end
)

function queryMapTimes (mapInfo, bStart)
	times = {}
	monthtimes = {}
	monthtTopTime = nil
	mapname = mapInfo.resname
	mapnameFull = mapInfo.name
	racemode = racemodes[ exports.race:getRaceMode() ] or "(NULL)"
	info = mapInfo
	local q = "SELECT t.forumid, t.mapname, t.pos, t.value, t.date, n.name, g.mta_name, v.options as supernick, h.country FROM toptimes t LEFT JOIN gc_nickcache n ON t.forumid = n.forumid LEFT JOIN country h ON t.forumid = h.forum_id LEFT JOIN mrgreengaming_gc.green_coins g ON t.forumid = g.forum_id LEFT JOIN vip_items v ON t.forumid = v.forumid and v.item = 2 WHERE t.mapname = ? ORDER BY t.pos"
	dbQuery(maptimes, {mapInfo, bStart}, handlerConnect, q, mapname)
	if not score[exports.race:getRaceMode()] then
		local q = "SELECT t.forumid, t.mapname, t.value, t.date, t.month,v.options as supernick, n.name, g.mta_name, h.country FROM toptimes_month t LEFT JOIN mrgreengaming_gc.green_coins g ON t.forumid = g.forum_id LEFT JOIN country h ON t.forumid = h.forum_id LEFT JOIN gc_nickcache n ON t.forumid = n.forumid LEFT JOIN vip_items v ON t.forumid = v.forumid and v.item = 2 WHERE t.mapname = ? ORDER BY date DESC"
		dbQuery(monthlytime, {mapInfo, bStart}, handlerConnect, q, mapname, getRealTime().month+1)
	else
		sendMonthTime()	-- send empty month time
	end
end


function maptimes(qh, mapInfo, bStart)
	local result = dbPoll(qh, 0)
	if not result then
		return outputDebugString('toptimes failed ' .. mapname, 2)
	elseif #result > 0 then
		if mapInfo.resname ~= mapname then
			return outputDebugString('toptimes mismatch ' .. mapname .. ' ' .. mapInfo.resname, 2)
		else
			times = result
			-- var_dump("-v", times)
		end
	else
		-- outputDebugString('new map ' .. mapInfo.resname)
	end

	times.resname = mapInfo.resname
	times.mapname = mapInfo.name
	times.modename = mapInfo.modename
	times.kills = score[mapInfo.modename]
	for k, player in ipairs(getElementsByType'player') do
		local forumid = exports.gc:getPlayerForumID(player)
		if forumid then
			for _, t in ipairs(times) do
				if forumid == t.forumid then
					t.player = player
					t.name = getElementData(player, "vip.colorNick") or getPlayerName(player)
					break
				end
			end
		end
	end
	for _, t in ipairs(times) do
		t.formatDate = FormatDate(t.date)
	end
	
	if not bStart then
		sendClientTimes()
	else
		setTimer(sendClientTimes, 1000, 1)
	end
end

function monthlytime(qh, mapInfo, bStart)
	local result = dbPoll(qh, 0)
	if not result then
		return outputDebugString('monthlytime failed ' .. mapname, 2)
	elseif #result > 0 then
		if mapInfo.resname ~= mapname then
			return outputDebugString('toptimes mismatch ' .. mapname .. ' ' .. mapInfo.resname, 2)
		else
			monthtimes = result
			if result[1].month == getRealTime().month+1 then
				monthtTopTime = result[1]
				-- var_dump("-v", times)
				monthtTopTime.resname = mapInfo.resname
				monthtTopTime.mapname = mapInfo.name
				monthtTopTime.modename = mapInfo.modename
				monthtTopTime.kills = score[mapInfo.modename]
				monthtTopTime.formatDate = FormatDate(monthtTopTime.date)
				for k, player in ipairs(getElementsByType'player') do
					local forumid = exports.gc:getPlayerForumID(player)
					if forumid and monthtTopTime.forumid == forumid then
						monthtTopTime.player = player
						monthtTopTime.name = getElementData(player, "vip.colorNick") or getPlayerName(player)
						break
					end
				end
			end
		end
	else
		-- outputDebugString('new map ' .. mapInfo.resname)
	end
	if not bStart then
		sendMonthTime()
	else
		setTimer(sendMonthTime, 1000, 1)
	end
end

function updatePosColumn(name)
	-- update pos column from previous map
	local q = "CALL updateTopPositions(?);"
	if times.kills then
		q = "CALL updateTopPositionsDesc(?);"
	end
	dbExec(handlerConnect, q, mapname)
	-- outputDebugString('updating pos map ' .. mapname)
end

addEventHandler('onResourceStop', resourceRoot, function()
	if mapname then
		updatePosColumn(mapname)
	end
end)

addEvent('clientstarted', true)
addEventHandler('clientstarted', resourceRoot, function()
	sendClientTimes(client)
end)

function getRaceInfo()
	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	return raceResRoot and getElementData( raceResRoot, "info" )
end

function sendClientTimes(player)
	triggerClientEvent(player or root, 'updateTopTimes', resourceRoot, times)
end

function sendMonthTime(player)
	triggerClientEvent(player or root, 'updateMonthTime', resourceRoot, monthtTopTime)
end



-------------------------
-- Adding new toptimes --
-------------------------

function updatePlayerTop(player, rank, value)
	local forumid = exports.gc:getPlayerForumID(player)
	local toptime = nil
	if isMapTesting() or not forumid then return end
	for i, row in ipairs(times) do
		if forumid == row.forumid then
			row.player = player
			toptime = row
			break
		end
	end
	
	if not score[exports.race:getRaceMode()] and rank == 1 and not (monthtTopTime and monthtTopTime.month ~= getRealTime().month+1) and (not monthtTopTime or (not times.kills and value < monthtTopTime.value) or (times.kills and value > monthtTopTime.value)) then
		local oldTime = monthtTopTime and monthtTopTime.value or nil
		
		-- dont reward first monthly top for a map

		local oldRewarded = 1
		if #monthtimes > 1 or (monthtimes[1] and monthtimes[1].month ~= getRealTime().month+1) then
			oldRewarded = 0
		end
		
		monthtTopTime = {}
		monthtTopTime.forumid = forumid
		monthtTopTime.value = value
		monthtTopTime.date = getRealTime().timestamp
		monthtTopTime.month = getRealTime().month+1
		
		monthtTopTime.resname = info.resname
		monthtTopTime.mapname = info.name
		monthtTopTime.modename = info.modename
		monthtTopTime.kills = score[info.modename]
		monthtTopTime.formatDate = FormatDate(monthtTopTime.date)
		monthtTopTime.player = player
		monthtTopTime.mta_name = getPlayerName(player)
		monthtTopTime.country = exports.geoloc:getPlayerCountry(player)
		monthtTopTime.rewarded = oldRewarded
		
		if oldTime then
			monthtimes[1] = monthtTopTime
		else
			table.insert(monthtimes, 2, monthtTopTime)
		end
		
		local q = "INSERT INTO toptimes_month VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE forumid = ?, value = ?, date=?;"
		dbExec(handlerConnect, q, forumid, info.resname, value, getRealTime().timestamp, getRealTime().month+1, oldRewarded, forumid, value, getRealTime().timestamp)
		sendMonthTime()
		monthtimeImprovement(player, value, oldTime, oldRewarded)
	end


	if not toptime or (not times.kills and value < toptime.value) or (times.kills and value > toptime.value) then
		local q
		local newPos, newTime, oldPos, oldTime
		newTime = value
		if not toptime then
			q = [[	
					INSERT INTO `toptimes`( `value`,`date`, `forumid`, `mapname`, `racemode` ) VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE date=VALUES(date), value=VALUES(value);
					INSERT INTO `maps`( `resname`,`mapname`, `racemode` ) VALUES (?,?,?) ON DUPLICATE KEY UPDATE resname=resname;
				]]
			table.insert(times, {forumid=forumid,mapname=mapname, value=value, date=getRealTime().timestamp, formatDate = FormatDate(getRealTime().timestamp), player=player, mta_name=getPlayerName(player), country = exports.geoloc:getPlayerCountry(player), new=true})
			-- outputDebugString('new top for ' .. getPlayerName(player))
			dbExec(handlerConnect, q, value, getRealTime().timestamp, forumid, mapname, racemode, mapname, mapnameFull, racemode)
		elseif (not times.kills and value < toptime.value) or (times.kills and value > toptime.value) then
			oldPos, oldTime = toptime.pos, toptime.value
			q = [[
					UPDATE `toptimes` SET `value`=?, `date`=? WHERE `forumid`=? AND `mapname`=?;
					UPDATE `maps` SET `mapname`=?, `racemode`=? WHERE `resname`=?;
				]]
			toptime.value = value
			toptime.date = getRealTime().timestamp
			toptime.formatDate = FormatDate(toptime.date)
			toptime.player = player
			toptime.mta_name=getPlayerName(player)
			toptime.country = exports.geoloc:getPlayerCountry(player)
			toptime.new=true
			-- outputDebugString('updated top for ' .. getPlayerName(player))
			dbExec(handlerConnect, q, value, getRealTime().timestamp, forumid, mapname, mapnameFull, racemode, mapname)
		end
		
		if not times.kills then
			table.sort(times, function(a,b) return a.value < b.value or (a.value == b.value and a.date < b.date) end)
		else
			table.sort(times, function(a,b) return a.value > b.value or (a.value == b.value and a.date < b.date) end)
		end
		sendClientTimes()
		for pos_, top in ipairs(times) do
			if top.forumid == forumid then
				newPos = pos_
				break
			end
		end
		toptimeImprovement( player, newPos, newTime, oldPos, oldTime, displayTopCount, #times )
	end
end

addEvent('onPlayerToptimeImprovement')
function toptimeImprovement( player, newPos, newTime, oldPos, oldTime, displayTopCount, getValidEntryCount )
	triggerEvent('onPlayerToptimeImprovement', player, newPos, newTime, oldPos, oldTime, displayTopCount, getValidEntryCount)
	if score[exports.race:getRaceMode()] then
		return
    elseif not oldPos then
		outputChatBox ( "A new personal time on this map:" , player, 255, 165, 0, true)
		outputChatBox ( "#" .. newPos .. ' ' .. timeMsToTimeText(newTime) , player, 255, 165, 0, true)
	else
		outputChatBox ( "Improved your personal time on this map:", player, 255, 165, 0, true)
		outputChatBox ( 'From #' .. oldPos .. " " .. timeMsToTimeText(oldTime) .. " to #" .. newPos .. " " .. timeMsToTimeText(newTime) .. " (-" .. timeMsToTimeText(oldTime - newTime) .. ")", player, 255, 165, 0, true)
    end
	if newPos == 1 then
		giveTop1Reward(player)
	end
end

addEvent('onPlayerMonthtimeImprovement')
function monthtimeImprovement( player, newTime, oldTime, rewarded )
	triggerEvent('onPlayerMonthtimeImprovement', player, newTime, oldTime)
	if score[exports.race:getRaceMode()] then
		return
    elseif rewarded == 0 then
		outputChatBox ( "You now have the monthly top on this map, if you hold it you will receive a reward at the end of the month" , player, 255, 165, 0, true)
	end
end

addEvent('onPlayerFinish')
addEventHandler('onPlayerFinish', root,
	function(rank, time)
	local forumid = exports.gc:getPlayerForumID(source)
		if forumid then
			updatePlayerTop(source, rank, time)
		else
			return outputChatBox("You need to login to your Green-Coins account in order to do toptimes!", source, 255, 0, 0, true)
		end
	end
, true, 'low')

-- [[
addEventHandler('onPlayerFinishDD', root,
	function(rank)
		local kills = tonumber(getElementData(source, 'kills'))
		if kills and kills > 0 then
			updatePlayerTop(source, rank, kills)
		end
	end
, true, 'low')
--]]

addEventHandler('onPlayerWinDD', root,
	function()
		-- timer to wait for clientside confirmation of a kill from the last killed guy
		setTimer(function(source)
			local kills = tonumber(getElementData(source, 'kills'))
			if kills and kills > 0 then
				updatePlayerTop(source, 1, kills)
			end
		end, 500, 1, source)
	end
, true, 'low')

-- [[
addEventHandler('onPlayerFinishShooter', root,
	function(rank)
		local kills = tonumber(getElementData(source, 'kills'))
		if kills and kills > 0 then
			updatePlayerTop(source, rank, kills)
		end
	end
, true, 'low')
--]]

addEventHandler('onPlayerWinShooter', root,
	function()
		-- timer to wait for clientside confirmation of a kill from the last killed guy
		setTimer(function(source)
			local kills = tonumber(getElementData(source, 'kills'))
			if kills and kills > 0 then
				updatePlayerTop(source, 1, kills)
			end
		end, 500, 1, source)
	end
, true, 'low')



addEventHandler('onPlayerFinishDeadline', root,
	function(rank)
		local kills = tonumber(getElementData(source, 'kills'))
		if kills and kills > 0 then
			updatePlayerTop(source, rank, kills)
		end
	end
, true, 'low')
--]]

addEventHandler('onPlayerWinDeadline', root,
	function()
		-- timer to wait for clientside confirmation of a kill from the last killed guy
		setTimer(function(source)
			local kills = tonumber(getElementData(source, 'kills'))
			if kills and kills > 0 then
				updatePlayerTop(source, 1, kills)
			end
		end, 500, 1, source)
	end
, true, 'low')
----------------
-- GC rewards --
----------------

-- Check for outstanding month rewards
local currentMonth = getRealTime().month+1
local checkedIDs = {}
function gcLogin ( forumid, amount )
	if checkedIDs[forumid] == getRealTime().month+1 then return end
	local player = source
	-- Check if player has unrewarded most monthly tops in the past months
	local q = [[
	SELECT forumid, month, c FROM (
		SELECT ANY_VALUE(forumid) forumid, month, ANY_VALUE(c) c FROM (
			SELECT forumid, month, COUNT(*) c FROM (
				SELECT * FROM `toptimes_month` ORDER BY date
			) AS dated WHERE rewarded = 0 GROUP BY forumid, month ORDER BY `month` ASC, `c`  DESC
		) AS counted GROUP BY month
	) AS maxs WHERE forumid = ? AND month != ?
	]]
	setTimer(function()
		if isElement(player) then
		dbQuery( mostMonthTops, {forumid, getPlayerSerial(player), getRealTime().month+1}, handlerConnect, q, forumid, getRealTime().month+1)
		end
	end, 10000, 1 )
end
addEventHandler("onGCLogin" , root, gcLogin )

function mostMonthTops ( qh, forumid, serial, month )
	local result = dbPoll(qh, 0)
	if not result then
		return outputDebugString('mostMonthTops failed ' .. tostring(forumid), 2)
	else
		-- Do query to check for unrewarded monthly tops
		local q = [[
		SELECT forumid, month, COUNT(*) count, GROUP_CONCAT(mapname) mapnames FROM `toptimes_month`
		WHERE forumid = ? AND rewarded = 0 AND month != ?
		GROUP BY forumid, month ORDER BY `toptimes_month`.`month` ASC
		]]
		dbQuery ( monthlyTops, {forumid, serial, getRealTime().month+1, result}, handlerConnect, q, forumid, getRealTime().month+1)
	end
end

function monthlyTops ( qh, forumid, serial, month, mostResult )
	local result = dbPoll(qh, 0)
	local player
	for _,p in ipairs(getElementsByType'player') do
		if getPlayerSerial(p) == serial then
			player = p
			break
		end
	end
	if not player or not isElement(player) or exports.gc:getPlayerForumID ( player ) ~= forumid then return end
	if not result then
		return outputDebugString('mostMonthTops failed ' .. tostring(forumid), 2)
	else
		checkedIDs[forumid] = month
		if #result > 0 then
			for i, r in ipairs(result) do
				outputChatBox("[GC] You had " .. r.count .. " monthly toptime(s) in " .. months[r.month] .. " and got " .. monthlyReward * r.count .. " GC", player, 0, 255, 0)
				exports.gc:addPlayerGreencoins(player, monthlyReward * r.count)
				outputConsole(months[r.month] .. ': ' .. r.mapnames, player)
			end
			dbExec(handlerConnect, 'UPDATE `toptimes_month` SET `rewarded`=1 WHERE `forumid`=? AND `month`!=? AND `rewarded`=0', forumid, month)
			if #mostResult > 0 then
				local s = "[GC] You had the most monthly toptimes in"
				for i, r in ipairs(mostResult) do
					s = s .. ' ' .. months[r.month]
					if i < #mostResult then
						s = s .. (i ~= #mostResult-1 and ',' or ' and')
					end
				end
				outputChatBox(s .. " and received " .. #mostResult * mostMonthlyReward .. " GC", player, 0, 255, 0)
				exports.gc:addPlayerGreencoins(player, #mostResult * mostMonthlyReward)
			end
		end
	end
end

function giveTop1Reward ( player )
	if not (#monthtimes > 1 or (monthtimes[1] and monthtimes[1].month ~= getRealTime().month+1)) then return end
	outputChatBox ( '[GC]'  .. getPlayerName(player) .. "#00FF00 earned " .. #monthtimes*baseTop1Reward .. " Green-Coins for the new top1", root, 0, 255, 0, true)
	exports.gc:addPlayerGreencoins(player, #monthtimes*baseTop1Reward)
end


--------------------------------------
-- Removing times / admin functions --
--------------------------------------
function adminOpenedToptimesManager(p,c)
	if not isAdminAuthorized(p) then return end
	if c == "deletetop" or c == 'deletealltops' then
		outputChatBox('/'..c..' is not in use anymore and may be removed in the future. Please use /managetops')
	end
	sendToptimesToAdmin(p)
end
addCommandHandler('managetops', adminOpenedToptimesManager )
addCommandHandler('deletetop', adminOpenedToptimesManager )
addCommandHandler('deletealltops', adminOpenedToptimesManager )

addEvent('adminRequestedUpdatedTops',true)
addEventHandler('adminRequestedUpdatedTops',resourceRoot,function()
	sendToptimesToAdmin(client)
end)

function sendToptimesToAdmin(admin)
	local amountToClient = 20
	local topsToClient = {}
	for i, v in ipairs(times) do
		if i > amountToClient then
			break
		end 
		table.insert(topsToClient,v)
	end
	triggerClientEvent(admin, 'onAdminRequestOpenTopManager', admin, mapname, topsToClient)
end


function adminConfirmedAction(theAction)
	if not isAdminAuthorized(client) then 
		outputChatBox('You are not authorized to remove toptimes',client,255,0,0)
		return 
	end

	-- Handle all top deletions here
	if theAction.action == "deletePlayerTop" then
		-- Delete Top action
		if theAction.mapname == mapname then
			-- Still the same map, search for the deleted top and remove it, then send to client
			for i, row in ipairs(times) do
				if row.forumid == theAction.forumid then
					table.remove(times,i)
					sendClientTimes()
					break
				end
			end
		end
		
		-- Insert into toptimes_deleted
		local toptimesDeletedQuery = "INSERT INTO toptimes_deleted (`forumid`,`mapname`,`pos`,`value`,`date`,`racemode`,`delete_reason`,`delete_admin`) SELECT a.forumid, a.mapname, a.pos, a.value, a.date, a.racemode, ?, ? FROM toptimes a WHERE a.forumid = ? AND a.mapname = ?"
		dbExec( handlerConnect, toptimesDeletedQuery, theAction.reason, getAccountName(getPlayerAccount(client)) or _getPlayerName(client), theAction.forumid, theAction.mapname)
		-- Delete from toptimes
		dbExec(handlerConnect, 'DELETE FROM toptimes WHERE forumid = ? and mapname = ?', theAction.forumid, theAction.mapname)
		
		outputChatBox('[TOPS] Top #' .. theAction.position .. ' by ' .. theAction.playername .. ' on map "'..theAction.mapname..'" was deleted by ' .. _getPlayerName(client), root, 255,50,50)

		deletelog(("Top #%d (%s %s) on map \"%s\" was deleted by %s (%s): %s"):format(theAction.position, timeMsToTimeText(theAction.value), theAction.playername, theAction.mapname, _getPlayerName(client), getAccountName(getPlayerAccount(client)), theAction.reason))
	
	elseif theAction.action == "deleteAllPlayerTops" then
		-- Delete All Player Tops
		for i, row in ipairs(times) do
			if row.forumid == theAction.forumid then
				table.remove(times,i)
				sendClientTimes()
				break
			end
		end
		
		-- Insert into toptimes_deleted
		local toptimesDeletedQuery = "INSERT INTO toptimes_deleted (`forumid`,`mapname`,`pos`,`value`,`date`,`racemode`,`delete_reason`,`delete_admin`) SELECT a.forumid, a.mapname, a.pos, a.value, a.date, a.racemode, ?, ? FROM toptimes a WHERE a.forumid = ?"
		dbExec( handlerConnect, toptimesDeletedQuery, theAction.reason, getAccountName(getPlayerAccount(client)) or _getPlayerName(client), theAction.forumid)
		-- Delete from toptimes
		dbExec(handlerConnect, 'DELETE FROM toptimes WHERE forumid = ? ', theAction.forumid)
		
		outputChatBox('[TOPS] All tops from player ' .. theAction.playername .. ' have been removed by ' .. _getPlayerName(client), root, 255,50,50)

		deletelog(("ALL tops by %s (forumid: %s) have been deleted by %s (%s): %s"):format(theAction.playername, theAction.forumid, _getPlayerName(client), getAccountName(getPlayerAccount(client)), theAction.reason))
	
	elseif theAction.action == "deleteAllMapTops" then
		-- Remove all tops, then send to client
		times = {}
		sendClientTimes()

		-- Insert into toptimes_deleted
		local toptimesDeletedQuery = "INSERT INTO toptimes_deleted (`forumid`,`mapname`,`pos`,`value`,`date`,`racemode`,`delete_reason`,`delete_admin`) SELECT a.forumid, a.mapname, a.pos, a.value, a.date, a.racemode, ?, ? FROM toptimes a WHERE a.mapname = ?"
		dbExec( handlerConnect, toptimesDeletedQuery, theAction.reason, getAccountName(getPlayerAccount(client)) or _getPlayerName(client), theAction.mapname)
		-- Delete from toptimes
		dbExec(handlerConnect, 'DELETE FROM toptimes WHERE mapname = ? ', theAction.mapname)

		outputChatBox('[TOPS] All tops from map  "' .. theAction.mapname .. '" have been removed by ' .. _getPlayerName(client), root, 255,50,50)
		deletelog(("ALL tops in map '%s' have been deleted by %s (%s): %s"):format(theAction.mapname, _getPlayerName(client), getAccountName(getPlayerAccount(client)), theAction.reason))

	end
end
addEvent('onAdminConfirmedToptimesDeletionAction', true)
addEventHandler( 'onAdminConfirmedToptimesDeletionAction', resourceRoot, adminConfirmedAction )

function deletemonthtop(p, c)
	if not isAdminAuthorized(p) then return end
	if not monthtTopTime then
		return outputChatBox('Month top not found', p)
	end
	dbExec(handlerConnect, 'DELETE FROM toptimes_month WHERE mapname = ? AND month = ?', monthtTopTime.resname, monthtTopTime.month)
	monthtTopTime = nil
	sendMonthTime()
	outputChatBox('Month top deleted', p)
end
addCommandHandler('deletemonthtop', deletemonthtop, true)

function deletelog ( msg)
	local f = fileExists'deleted_tops.log' and fileOpen'deleted_tops.log' or fileCreate'deleted_tops.log'
	fileSetPos( f, fileGetSize( f ) )
	fileWrite(f, FormatDate(nil, true) .. ' ' .. msg .. '\n')
	fileClose(f)
end

local modes={
	race={race=true},
	mix={nts=true,dd=true,rtf=true,sh=true,ctf=true},
}

function checkResources()
	if true then return end	-- Fuck deletes
	local m = modes[get'server']
	local m2 = modes[get'server'=='race' and 'mix' or 'race']
	if not m then
		return outputChatBox("WARNING: SET THE TOPTIMES SERVER TYPE!", root, 255,0,0)
	end
	dbQuery(function(qh)
		local result = dbPoll(qh, 0)
		if not result then
			return outputDebugString('checkResources failed ', 2)
		else
			for _, r in ipairs(result) do
				local name = string.lower(r.mapname)
				if not (getResourceFromName(name) or m2[split(name, '-')[1]]) then
					outputDebugString('Deleting ' .. name .. ' monthly toptimes')
					dbExec(handlerConnect, 'DELETE FROM toptimes_month WHERE mapname=?', name)
				end
			end
		end
	end, handlerConnect, 'SELECT mapname FROM `toptimes_month` GROUP BY mapname' )

end


-------------------
-- Checking tops --
-------------------

addCommandHandler('oldtops', 
	function(p, cmd, name, ex)
		local player = string.lower(name or _getPlayerName(p))
		ex= tonumber(ex) or 3
		local count = {}
		if ex < 1 or ex > 10 then ex = 1 end
		for a=1,ex do
			count [a] = 0
		end
		local map_names = {}
		for k, v in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName('race'))) do
			map_names['race maptimes Sprint ' .. (getResourceInfo(v, 'name' ) or getResourceName(v))] = v
		end
		
		local maps_table = executeSQLQuery( "SELECT tbl_name FROM sqlite_master WHERE tbl_name LIKE 'race maptimes Sprint %' " )
		for k, v in ipairs(maps_table) do
		
			local mapTable = v.tbl_name
			if map_names[mapTable] then
				local mapTimes = executeSQLQuery( "SELECT playerName FROM ? LIMIT ?", mapTable, tostring(ex) )
				for i, t in ipairs ( mapTimes ) do
					if string.lower(t.playerName) == player then
						outputConsole(mapTable)
						count [i] = count[i] + 1
					end
				end
			end
			
		end
		
		outputChatBox(player .. ' old toptimes: ' , p)
		local player = name or _getPlayerName(p)
		for a=1,ex do
			outputChatBox('* Top' .. a .. '\'s = ' .. count [a] , p)
		end
	end
)

addCommandHandler('tops',
	function(p, cmd, ex)
		ex = tonumber(ex)
		ex = ex and ex < 11 and ex or 3 
		local forumid = exports.gc:getPlayerForumID(p)
		if not forumid then
			return outputChatBox("You are not logged in to Greencoins!", p, 255, 0, 0, true)
		end
		dbQuery(function(qh)
			local result = dbPoll(qh, 0)
			if not result then
				return outputDebugString('/tops failed ' .. forumid, 2)
			elseif #result == 0 then
				outputChatBox("You have no tops!", p, 255, 0, 0, true)
			else
				outputChatBox('Your toptimes: ' , p, 0, 255, 0, true)
				for pos = 1,ex do
					local r = nil
					for _,row in ipairs(result) do
						if pos == row.pos then
							r = row
							break
						end
					end
					if not r then
						outputChatBox('* Top' .. pos .. '\'s = #FFFFFF' .. 0 , p, 0, 255, 0, true)
					else
						outputChatBox('* Top' .. pos .. '\'s = #FFFFFF' .. r.count , p, 0, 255, 0, true)
						outputConsole(r.mapnames)
					end
				end
			end
		end, handlerConnect, "SELECT pos, count(*) count, GROUP_CONCAT(mapname SEPARATOR ', ') mapnames FROM `toptimes` WHERE forumid=? and pos <= ? GROUP BY pos ORDER BY pos", forumid, ex)
	end
)

-------------
-- utility --
-------------
function isAdminAuthorized(player)
	local accountName = getAccountName( getPlayerAccount(player) )
	if not isGuestAccount( getPlayerAccount(player) ) and isObjectInACLGroup( "user."..accountName, aclGetGroup("mapmanager") ) or isObjectInACLGroup( "user."..accountName, aclGetGroup("ServerManager") ) then
		return true
 end
	return false
end

function FormatDate(timestamp, full)
	local t =  getRealTime(timestamp)
	if full then
		return string.format("%02d/%02d/'%02d %02d:%02d:%02d", t.monthday, t.month+1, t.year - 100, t.hour, t.minute, t.second)
	end
	return string.format("%02d.%02d.%02d", t.monthday, t.month+1, t.year + 1900)
end

function timeMsToTimeText( timeMs )

	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;

	return string.format( '%02d:%02d:%03d', minutes, seconds, ms );
end

function _getPlayerName ( player )
	return removeColorCoding ( getPlayerName ( player ) )
end

function isMapTesting()
	return getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), 'newupload') == "true"
end

-- modifiers: v - verbose (all subtables), n - normal, s - silent (no output), dx - up to depth x, u - unnamed
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



----------------------------------------------------------------------------
--------------- Get the country of a player for flags ----------------------
----------------------------------------------------------------------------

addEventHandler("onGCLogin" , root, 
function(forumID)
	getPlayerCountry(source, forumID)
end
)

function getPlayerCountry(player,forumID)
	if not handlerConnect then return end
	
	local country = exports.geoloc:getPlayerCountry(player)
	local playerName = getPlayerName(player)
	
	if country == "A1" then return end --if country is "Anonymous Proxy" - ignore and add country manually using /addcountry
	
	local query = dbQuery ( handlerConnect, "SELECT * FROM country WHERE forum_id = ?", forumID)
	local results = dbPoll ( query, -1 )
	if results and #results > 0 then		
		local country_sql = results[1].country
		if country_sql == country then 
			return
		else
			addPlayerCountryToDB(playerName, forumID, country)
		end
	else
		addPlayerCountryToDB(playerName, forumID, country)
	end
end

function addPlayerCountryToDB(playerName, forumID, country)
	local query = dbExec(handlerConnect,"REPLACE INTO `country` (forum_id, country) VALUES (?,?)", forumID, country)
	if query then
		outputDebugString("Added country code for player: "..playerName..". Country code: "..country)
	else
		outputDebugString("Failed to add country code for player: "..playerName.. ". Country code: "..country, 1)
	end
end


function addcountry(p, c, pos, code)
	pos = tonumber(pos)
	if not (pos and times[pos]) then
		return outputChatBox('Top not found ' .. tostring(pos), p)
	elseif not code then
		return outputChatBox('Syntax: /addcountry <position> <country code>', p)
	end
	
	local query = dbExec(handlerConnect, "REPLACE INTO `country` (forum_id, country) VALUES (?,?)", times[pos].forumid, code)

	if query then
		outputDebugString("Added country code for player: "..times[pos].mta_name..". Country code: "..code)
		outputChatBox("Added country code for player: "..times[pos].mta_name..". Country code: "..code, p)
	else
		outputDebugString("Failed to add country code for player: "..times[pos].mta_name.. ". Country code: "..code, 1)
		outputChatBox("Failed to add country code for player: "..times[pos].mta_name.. ". Country code: "..code, p)
	end
end
addCommandHandler('addcountry', addcountry, true)



---------------------------------------------------------------------------------------
------------------------ Cache toptimes for every racemode ----------------------------
---------------------------------------------------------------------------------------
local positionsToCache = 3
local toptimesCache = {}

function cacheToptimes(forumID)
	cachePlayerToptimes( { forumID } )
end
addEventHandler("onGCLogin" , root, cacheToptimes)

function cleanToptimesCache (forumID)
	toptimesCache[forumID] = nil
end
addEventHandler("onGCLogout" , root, cleanToptimesCache )

addEventHandler("onResourceStart", resourceRoot, 
	function()
		queryTopsAll()
	end
)

function queryTopsAll()
	local resGC = getResourceFromName'gc'
	if not resGC or getResourceState ( resGC ) ~= 'running' then return false end
	
	local forumids = {}
	for _, player in ipairs(getElementsByType'player') do 
		local forumID = exports.gc:getPlayerForumID (player)
		if forumID then
			table.insert(forumids, forumID)
		end
	end
	
	if #forumids > 0 then 
		cachePlayerToptimes(forumids)
	end
end

function cachePlayerToptimes(tableForumIDs)
	if not handlerConnect then return end
	
	forumids = table.concat(tableForumIDs, ',')
	
	dbQuery(function(qh)
		local result = dbPoll(qh, -1)
		if not result then 
			outputDebugString("cachePlayerToptimes() - Error: Query not ready or error") 
			return false 
		else
			for _, id in pairs(tableForumIDs) do
				toptimesCache[id] = {}
			end
			
			for _, row in ipairs(result) do
				if not toptimesCache[row.forumid] then toptimesCache[row.forumid] = {} end
				
				local racemodes = split(row.racemodes, ", ")
				for _, racemode in pairs(racemodes) do
					if not toptimesCache[row.forumid][racemode] then toptimesCache[row.forumid][racemode] = {} end
					toptimesCache[row.forumid][racemode][row.pos] = (toptimesCache[row.forumid][racemode][row.pos] or 0) + 1
				end
			end
		end
	end, handlerConnect, "SELECT a.forumid, a.pos, GROUP_CONCAT(b.racemode SEPARATOR ', ') racemodes FROM toptimes a, maps b WHERE a.forumid IN(??) and a.pos <= ? and a.mapname = b.resname GROUP BY a.pos, a.forumid", forumids, positionsToCache)
end

addEvent("onPlayerToptimeImprovement")
addEventHandler("onPlayerToptimeImprovement", root, 
	function(newPos, newTime, oldPos, oldTime)
		local forumID = exports.gc:getPlayerForumID(source)
		if not forumID then return end
		
		if newPos <= positionsToCache then
			g_newTops = true
		end
	end
)

addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', getRootElement(),
	function(state)
		if state == "GridCountdown" and g_newTops then --right after updatePosColumn()
			queryTopsAll()
		elseif state == "Running" then
			g_newTops = false
		end
	end
)

-------------------------
--- Exported function ---
-------------------------
function getPlayerToptimes(forumID)
	if type(forumID) ~= "number" then return false end
	if not toptimesCache[forumID] then return false end
	
	return toptimesCache[forumID]
end

function getPlayerToptimesByRacemode(forumID, racemode)
	if type(forumID) ~= "number" then return false end
	if not racemode then return false end
	if not toptimesCache[forumID] then return false end
	
	return toptimesCache[forumID][racemode]
end
