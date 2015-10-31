---
-- Main client file with drawing and calculating.
--
-- @author	driver2
-- @copyright	2009-2010 driver2
--
-- Recent changes:
-- 2010-02-09: Made GUI-key a setting in defaultSettings.lua, added help to radio buttons, replaced "infocenter" with "gamecenter"

-------------------------
-- Initialize Settings --
-------------------------

local gamecenterResource = false
settingsObject = Settings:new(defaultSettings,"@settings.xml")

local function s(setting,settingType)
	return settingsObject:get(setting,settingType)
end


-----------------------------
-- Variables and Constants --
-----------------------------

fonts = {"default","default-bold","clear","arial","sans","pricedown","bankgothic","diploma","beckett"}

local screenWidth,screenHeight = guiGetScreenSize()
local x = nil
local y = nil
local x2 = nil
local y2 = nil
local h = nil
local readyToDraw = false
local mapLoaded = false
local screenFadedOut = false
local updateIntervall = 2000

local g_CheckpointDistance = {}
local g_CheckpointDistanceSum = {}
local g_players = {}
local g_TotalDistance = 0
local g_recordedDistances = {}
local g_recordedDistancesForReplay = {}
local g_times = {}

------------
-- Events --
------------

function initiate()
	settingsObject:loadFromXml()
	mapStarted()
	sendMessageToServer("loaded")
end
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),initiate)

function mapStarted()
	-- Start under the assumption that no checkpoints are found,
	-- so not ready to draw (also the new data hasn't been loaded
	-- yet)
	readyToDraw = false
	mapLoaded = false
	setTimer(function()
	if loadMap() then
		-- If data was successfully loaded, prepare drawing
		mapLoaded = true
		calculateCheckpointDistance()
		prepareDraw()
	end
	end, 500, 1)
	g_times = {}
	g_delay = {}
	-- TODO: load distances for map
	g_recordedDistancesForReplay = g_recordedDistances
	g_recordedDistances = {}
	g_replayCount = 0
end
addEventHandler("onClientMapStarting",getRootElement(),mapStarted)

-------------------------------
-- Load and prepare map data --
-------------------------------
function loadMap()
	--local res = call(getResourceFromName("mapmanager"),"getRunningGamemodeMap")
	-- Get the data or empty tables, if none of these elements exist
	g_Spawnpoints = getAll("spawnpoint")
	g_Checkpoints = getAll("checkpoint")
	if exports.race:getRaceMode() == 'Reach the flag' then
		flagObjects = getElementsByType('rtf')
		if flagObjects[1] then
			local position = {
			tonumber(getElementData(flagObjects[1],"posX")),
			tonumber(getElementData(flagObjects[1],"posY")),
			tonumber(getElementData(flagObjects[1],"posZ")),
			}
			g_Checkpoints = { { position = position } }
		end

		-- Code from before new EDF map structure
		-- for _, object in ipairs(getElementsByType('object')) do 
		-- 	if (getElementModel(object) == 2914) then
		-- 		local position = {
		-- 					tonumber(getElementData(object,"posX")),
		-- 					tonumber(getElementData(object,"posY")),
		-- 					tonumber(getElementData(object,"posZ"))
		-- 				}
		-- 		g_Checkpoints = { { position = position } }
		-- 	end
		-- end
	end
	if #g_Spawnpoints > 0 and #g_Checkpoints > 0 then
		return true
	end
	outputConsole('Progress bar error')
	testprog()
	return false
end

function testprog()
	local spawns_index = false
	local spawns_total = false
	for k, v in pairs(g_Spawnpoints) do
		if not spawns_index or spawns_total then
			spawns_index = k
			spawns_total = 0
		end
		spawns_total = spawns_total + 1
	end
	local Checks_index = false
	local Checks_total = false
	for k, v in pairs(g_Checkpoints) do
		if not Checks_index or Checks_total then
			Checks_index = k
			Checks_total = 0
		end
		Checks_total = Checks_total + 1
	end
	var_dump('dump', true, 'mapLoaded', mapLoaded, 'g_TotalDistance', g_TotalDistance, '#g_Spawnpoints', #g_Spawnpoints, '#g_Checkpoints', #g_Checkpoints, 'getAll("spawnpoint")', getAll("spawnpoint"), 'getAll("checkpoint")', getAll("checkpoint"), 'spawns_index', spawns_index, "spawns_total", spawns_total, "Checks_index", Checks_index, 'Checks_total', Checks_total)
end
addCommandHandler('testprog', testprog)

--[[
[NTS]Sunday na play again limit reached
dump: string(11) "readyToDraw"
boolean "false"
s("enabled"): boolean "true"
screenFadedOut: boolean "false"

--]]

function getAll(name)
	local result = {}
	for i,element in ipairs(getElementsByType(name)) do
		result[i] = {}
		result[i].id = getElementID(element) or i
		local position = {
					tonumber(getElementData(element,"posX")),
					tonumber(getElementData(element,"posY")),
					tonumber(getElementData(element,"posZ"))
				}
		result[i].position = position;
	end
	return result
end

function calculateCheckpointDistance()
	local total = 0
	local cps = {}
	local cpsSum = {}
	local pos = g_Spawnpoints[1].position
	local prevX, prevY, prevZ = pos[1],pos[2],pos[3]
	for k,v in ipairs(g_Checkpoints) do
		local pos = v.position
		if prevX ~= nil then
			local distance = getDistanceBetweenPoints3D(pos[1],pos[2],pos[3],prevX,prevY,prevZ)
			total = total + distance
			cps[k] = distance
			cpsSum[k] = total
		end
		prevX = pos[1]
		prevY = pos[2]
		prevZ = pos[3]
	end
	g_CheckpointDistance = cps
	g_CheckpointDistanceSum = cpsSum
	g_TotalDistance = total
end



-----------
-- Times --
-----------

-- SHOULD BE DONE: maybe reset data if player rejoins? maybe check if he already passed that checkpoint


--[[
-- Adds the given time for the player at that checkpoint to the table,
-- as well as displays it, if there is a time at the same checkpoint
-- to compare it with.
--
-- @param   player   player: The player element
-- @param   int      checkpoint: The checkpoint number
-- @param   int      time: The number of milliseconds
-- @return  boolean  false if parameters are invalid
-- ]]
function addTime(player,checkpoint,time)
	if player == nil then
		return false
	end
	if g_times[player] == nil  then
		g_times[player] = {}
	end
	g_times[player][checkpoint] = time
	
	if player == getLocalPlayer() then
		-- For players who passed the checkpoint you hit before you	
		for k,v in ipairs(getElementsByType("player")) do
			local prevTime = getTime(v,checkpoint)
			--var_dump("prevTime",prevTime)
			if prevTime then
				local diff = time - prevTime
				g_delay[v] = {diff,getTickCount()}
			end
		end
	else
		-- For players who hit a checkpoint you already passed
		local prevTime = getTime(getLocalPlayer(),checkpoint)
		if prevTime then
			local diff = -(time - prevTime)
			g_delay[player] = {diff,getTickCount()}
		end
	end
end

--[[
-- Gets the time of a player for a certain checkpoint, if it exists
-- and the player has already reached it (as far as race is concerned)
--
-- @param   player   player: The player element
-- @param   int      checkpoint: The checkpoint number
-- @return  mixed    The number of milliseconds passed for this player
-- 			at this checkpoint, or false if it doesn't exist
-- ]]
function getTime(player,checkpoint)
	-- Check if the desired time exists
	if g_times[player] ~= nil and g_times[player][checkpoint] ~= nil then
		-- Check if player has already reached that checkpoint. This prevents
		-- two scenarios from causing wrong times to appear:
		-- 1. When a player is set back to a previous checkpoint when he dies twice
		-- 2. When a player rejoins and the player element remains the same (with the times still being saved
		--    at the other clients)
		local playerHeadingForCp = getElementData(player,"race.checkpoint")
		if type(playerHeadingForCp) == "number" and playerHeadingForCp > checkpoint then
			return g_times[player][checkpoint]
		end
	end
	return false
end

--[[
-- Calculates minutes and seconds from milliseconds
-- and formats the output in the form xx:xx.xx
--
-- Also supports negative numbers, to which it will add a minus-sign (-)
-- before the output, a plus-sign (+) otherwise.
--
-- @param   int     milliseconds: The number of milliseconds you wish to format
-- @return  string  The formated string or an empty string if no parameter was specified
-- ]]
function formatTime(milliseconds)
	if milliseconds == nil then
		return ""
	end
	local prefix = "+"
	if milliseconds < 0 then
		prefix = "-"
		milliseconds = -(milliseconds)
	end
	local minutes = math.floor(milliseconds / 1000 / 60)
	local milliseconds = milliseconds % (1000 * 60)
	local seconds = math.floor(milliseconds / 1000)
	local milliseconds = milliseconds % 1000

	return string.format(prefix.."%i:%02i.%03i",minutes,seconds,milliseconds)
end



-------------------
-- Communication --
-------------------

function serverMessage(message,parameter)
	if message == "update" then
		addTime(parameter[1],parameter[2],parameter[3])
	end
	if message == "times" then
		g_times = parameter
	end
end
addEvent("onClientRaceProgressServerMessage",true)
addEventHandler("onClientRaceProgressServerMessage",getRootElement(),serverMessage)

function sendMessageToServer(message,parameter)
	triggerServerEvent("onRaceProgressClientMessage",getRootElement(),message,parameter)
end


----------------------------
-- Update player position --
----------------------------

function getVehicleFromPlayer(player)
	for k,v in pairs(getElementsByType("vehicle")) do
		if getVehicleController(v) == player then
			return v
		end
	end
	return false
end

function update()
	-- If not checkpoints are present on the current map,
	-- we don't need to do anything.
	if not mapLoaded then
		return
	end
	-- Start with an empty table, this way players
	-- won't have to be removed, but simply not added
	local players = {}
	-- Go through all current players
	for k,player in ipairs(getElementsByType("player")) do
		if not getElementData(player,"race.finished") then
			local headingForCp = getElementData(player,"race.checkpoint") or 1
			local distanceToCp = distanceFromPlayerToCheckpoint(player,headingForCp)
			if distanceToCp ~= false then
				-- Add with numeric index to make shuffling possible
				table.insert(players,{getPlayerName(player),calculateDistance(headingForCp,distanceToCp),player})
				--players[v] = calculateDistance(headingForCp,distanceToCp)
			end
		end
	end

	-- Test players
	--table.insert(players,{"a",1100})
	--table.insert(players,{"b",1100})	
	--table.insert(players,{"c",1100})
	--table.insert(players,{"d",1100})
	--table.insert(players,{"e",1100})
	--table.insert(players,{"f",1100})
	--table.insert(players,{"g",1100})
	--table.insert(players,{"norby890",11})
	--table.insert(players,{"AdnanKananda",100})
	--table.insert(players,{"Player234",900})
	--table.insert(players,{"Kray-Z",1050})
	--table.insert(players,{"SneakyViper",1100})
	
	-- Find local player and add his distance to an extra variable
	-- (since it can't simply be access via the index anymore, because of the numeric indexes)
	g_localPlayerDistance = nil
	for _,table in pairs(players) do
		if table[1] == getPlayerName(getLocalPlayer()) then
			g_localPlayerDistance = table[2]
		end
	end

	--[[
	if g_localPlayerDistance ~= nil and g_localPlayerDistance > 0 then
		g_replayCount = g_replayCount + 1
		local replayDistance = g_recordedDistancesForReplay[g_replayCount]
		if replayDistance ~= nil then
			table.insert(players,{"replay",replayDistance})
		end
		table.insert(g_recordedDistances,g_localPlayerDistance)
	end
	]]

	-- Sort the players if enabled
	if s("sortMode") == "length" then
		table.sort(players,function(w1,w2) if w1[1]:len() > w2[1]:len() then return true end end)
	elseif s("sortMode") == "shuffle" then
		shuffle(players)
	elseif s("sortMode") == "rank" then
		table.sort(players,function(w1,w2) if w1[2] < w2[2] then return true end end)
	end

	-- Prefer players directly in front and behind you if enabled
	if s("preferNear") and g_localPlayerDistance ~= nil then
		local prevNick = nil
		local playerBefore = nil
		local playerAfter = nil
		local playerBeforeKey = 0
		local playerAfterKey = 0
		for key,table in pairs(players) do
			--outputChatBox(tostring(g_localPlayerDistance))
			if table[2] > g_localPlayerDistance then
				if playerBefore == nil or table[2] < playerBefore[2] then
					playerBefore = table
					playerBeforeKey = key
				end
			end
			if table[2] < g_localPlayerDistance then
				if playerAfter == nil or table[2] > playerAfter[2] then
					playerAfter = table
					playerAfterKey = key
				end
			end
		end
		if playerAfterKey ~= 0 then
			table.insert(players,table.remove(players,playerAfterKey))
			-- Correct the index if needed (because the indices may have shifted,
			-- which would cause the playerBeforeKey not to be correct anymore)
			if playerBeforeKey > 0 then
				playerBeforeKey = playerBeforeKey - 1
			end
		end
		if playerBeforeKey ~= 0 then
			table.insert(players,table.remove(players,playerBeforeKey))
		end
	end

	-- Finally, copy the table to the global variable to be used for drawing.
	g_players = players
end
setTimer(update,updateIntervall,0)

-- see: http://en.wikipedia.org/wiki/Fisher-Yates_shuffle


function shuffle(t)
  local n = #t
 
  while n > 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
 
  return t
end


function distanceFromPlayerToCheckpoint(player, i)
	-- TODO: check if the index exists
	local checkpoint = g_Checkpoints[i]
	if checkpoint == nil then
		return false
	end
	local x, y, z = getElementPosition(player)
	return getDistanceBetweenPoints3D(x, y, z, unpack(checkpoint.position))
end
function calculateDistance(headingForCp,distanceToCp)
	local sum = g_CheckpointDistanceSum[headingForCp]
	if sum == nil then
		return false
	end
	local checkpointDistance = g_CheckpointDistance[headingForCp]
	if distanceToCp > checkpointDistance then
		distanceToCp = checkpointDistance
	end
	return sum - distanceToCp
end
function calculateDistance2(headingForCp,distanceToCp)
	local sum = 0
	for k,v in ipairs(g_CheckpointDistance) do
		sum = sum + v
		if headingForCp == k then
			if distanceToCp > v then
				distanceToCp = v
			end
			sum = sum - distanceToCp
			return sum
		end
	end
	return 0
end

-------------
-- Drawing --
-------------

--[[
-- Prepares the drawing by calculating the position and
-- setting some needed variables.
-- ]]
function prepareDraw()
	-- DONE: maybe add a check if checkpoints are actually loaded (since this is also called when settings are changed)
	if not mapLoaded then
		return
	end
	-- Variables that stay the same (until settings are changed)
	font = s("fontType")
	fontScale = s("fontSize")
	fontHeight = dxGetFontHeight(s("fontSize"),s("fontType"))
	local widthToTheRight = 20
	if s("drawDistance") then
		widthToTheRight = widthToTheRight + dxGetTextWidth("00.00",fontScale,font) + 20
	end
	if s("drawDelay") then
		widthToTheRight = widthToTheRight + dxGetTextWidth("00:00.00",fontScale,font) + 20
	end
	--outputChatBox(tostring(widthToTheRight))
	-- Position and height
	x = math.floor(s("left") * screenWidth) - widthToTheRight
	y = math.floor(s("top") * screenHeight)
	h = math.floor(s("size") * screenHeight)
	x2 = x
	y2 = y + h
	pixelPerMeter = h / g_TotalDistance
	scale = g_TotalDistance / 4
	
	-- Ready preparing, can start drawing if necessary
	readyToDraw = true
end

--[[
-- This actually draws all the stuff on the screen.
-- ]]
function draw()
	--zeitmessungBeginn = getTickCount()
	--drawText("test",500,500,tocolor(255,255,255,255))
	-- Check if drawing is enabled
	if not readyToDraw or not s("enabled") or screenFadedOut then
		return
	end

	-- Initialize Variables needed
	local backgroundColor = getColor("background")
	local fontColor = getColor("font")
	local color = getColor("font")
	local localPlayerName = getPlayerName(getLocalPlayer())

	-- Dertemine local Players distance
	local localPlayerDistance = g_localPlayerDistance
	local localPlayerLevel = nil
	if localPlayerDistance ~= nil then
		-- TODO: to round or not to round
		localPlayerLevel = math.floor(y + h - localPlayerDistance*pixelPerMeter + 0.5)
	else
		localPlayerDistance = g_TotalDistance
	end
	--dxDrawText(tostring(localPlayerDistance),0,0,0)

	--dxDrawLine(x,y,x2,y2,tocolor(0,0,0))
	--dxDrawRectangle(x-5,y-1,10,h+2,tocolor(255,255,255,40))
	
	--------------------
	-- Draw Progress Bar
	--------------------
	local outlineColor = tocolor(0,0,0,200)
	local outlineColor2 = tocolor(0,0,0,120)
	-- Left border
	dxDrawLine(x-5,y-1,x-5,y+h-1,outlineColor)
	dxDrawLine(x-6,y-1,x-6,y+h-1,outlineColor)
	-- Right border
	dxDrawLine(x+4,y-1,x+4,y+h-1,outlineColor)
	dxDrawLine(x+5,y-1,x+5,y+h-1,outlineColor)
	
	-- Top border
	dxDrawLine(x-5,y-1,x+5,y-1,outlineColor)
	dxDrawLine(x-5,y-2,x+5,y-2,outlineColor2)
	-- Bottom border
	dxDrawLine(x-5,h+y-1,x+4,h+y-1,outlineColor)
	dxDrawLine(x-5,h+y,x+4,h+y,outlineColor2)
	
	-- Background
	dxDrawRectangle(x-4,y,8,h,getColor("bar"))
	-- Current local player progress
	if localPlayerLevel ~= nil then
		dxDrawRectangle(x-4,localPlayerLevel,8,y + h- localPlayerLevel - 1,getColor("progress"))
	end
	
	--dxDrawImage(x - 34, y-6, 20, 12, "finish2.png")

	-- Draw the total distance (if enabled)
	if s("drawDistance") then
		local totalDistanceOutput = g_TotalDistance
		if s("mode") == "miles" then
			totalDistanceOutput = totalDistanceOutput / 1.609344
		end
		drawText(string.format("%.2f",totalDistanceOutput/1000).." "..s("mode"),x + 18,y - fontHeight / 2,fontColor,backgroundColor)
	end
	
	--for i=g_TotalDistance,g_TotalDistance,scale do
	--	local text = 
		--dxDrawText(tostring(fontHeight),0,0)
		--dxDrawText(text,x + 12,y + h - i*pixelPerMeter - fontHeight / 2,tocolor(255,255,255,255),fontScale,font)
		
	--end
	--
	
	-------------------------------------------
	-- Draw all players except the Local Player
	-------------------------------------------
	local myRank = tonumber(getElementData(localPlayer, 'race rank'))
	local showLocalPlayer = true
	for pos,value in pairs(g_players) do
		local rank
		if isElement(value[3]) then
			rank = tonumber(getElementData(value[3], 'race rank'))
		end	
		-- if myRank and rank and (math.abs(myRank-rank) < 6 or rank == 1) and getPedOccupiedVehicle(value[3]) and not isVehicleDamageProof(getPedOccupiedVehicle(value[3])) then       
		if myRank and rank and getPedOccupiedVehicle(value[3]) and not isVehicleDamageProof(getPedOccupiedVehicle(value[3])) then       
		local playerName = value[1]
		playerName = string.gsub ( playerName, '#%x%x%x%x%x%x', '' )
		local playerDistance = value[2]
		local playerElement = value[3]
		local delay = nil
		local delayPassed = nil
		if g_delay[playerElement] ~= nil then
			delay = g_delay[playerElement][1]
			delayPassed = getTickCount() - g_delay[playerElement][2]
		end
		-- TODO: check if this works (instead of checking the playername)
		if playerElement ~= getLocalPlayer() then
			local level = y + h - playerDistance*pixelPerMeter
			local distance = 0
			if localPlayerLevel ~= nil then
				if math.abs(localPlayerLevel - level) < 10 then
					showLocalPlayer = false;
				end
			end
			-- localPlayerDistance should never be nil
			--if localPlayerDistance ~= nil then
				distance = playerDistance - localPlayerDistance
			--end
			
			-- prepare actual output
			if s("mode") == "miles" then
				distance = distance / 1.609344
			end
			if distance > 0 then
				distance = string.format("+%.2f",distance/1000)
			else
				distance = string.format("%.2f",distance/1000)
			end
			local textWidth = dxGetTextWidth(tostring(rank)..getPrefix(rank)..': '..playerName,fontScale,font)
			--dxDrawImage(x-15,level-10,40,15.5,"car.png",90,0,0,tocolor(0,0,0,255)) -- 194x75 2,58
			dxDrawRectangle(	x - 10,			level,		20,	2,	color)
			if rank == 1 then
				drawText(tostring(rank)..getPrefix(rank)..': '..playerName,	x - textWidth - 20,	level - fontHeight / 2,tocolor(255, 0, 0),backgroundColor)
			else
				drawText(tostring(rank)..getPrefix(rank)..': '..playerName,	x - textWidth - 20,	level - fontHeight / 2,fontColor,backgroundColor)
			end	
			local indent = 20
			if s("drawDistance") then
				drawText(distance,x+ indent, level - fontHeight / 2,fontColor,backgroundColor)
				indent = indent + dxGetTextWidth(distance,fontScale,font) + 20
			end
			if s("drawDelay") and delay ~= nil then
				local stayTime = 8000
				local fadeOutTime = 4000
				if delayPassed < fadeOutTime + stayTime or isGuiVisible() then
					local fade = 1
					if delayPassed > stayTime and not isGuiVisible() then
						fade = (fadeOutTime - delayPassed + stayTime) / fadeOutTime
					end
					drawText(formatTime(delay),x+indent,level-fontHeight/2,getColor("fontDelay",fade),getColor("backgroundDelay",fade))	
				end
				--drawText(formatTime(delay),x+40+dxGetTextWidth(distance,fontScale,font),level-fontHeight/2,tocolor(255,255,255,100),tocolor(0,0,0,0))
					
				
			end
		end
		end
	end
	--------------------
	-- Draw local player
	--------------------
	
	-- Draw only if player hasn't finished
	if localPlayerDistance == g_TotalDistance then
		return
	end
	local fontColor = getColor("font2")
	local backgroundColor = getColor("background2")
	dxDrawRectangle(x - 10,localPlayerLevel,20,2,fontColor)
	if showLocalPlayer then
		local textWidth = dxGetTextWidth(localPlayerName,fontScale,font)
		local leftX = x - textWidth - 20
		local topY = localPlayerLevel - fontHeight / 2
		
		drawText(localPlayerName,leftX,topY,fontColor,backgroundColor)
		if s("mode") == "miles" then
			localPlayerDistance = localPlayerDistance / 1.609344
		end
		if s("drawDistance") then
			drawText(string.format("%.2f",localPlayerDistance/1000),x + 20,localPlayerLevel - fontHeight / 2,fontColor,backgroundColor)
		end
	end

	--zeitmessung = getTickCount() - zeitmessungBeginn
	--dxDrawText(tostring(zeitmessung),0,0,0)
	
end
addEventHandler("onClientRender",getRootElement(),draw)

function getPrefix(number)
	if number == 11 or number == 12 or number == 13 then
		return 'th'
	end	
	number = number % 10
	if number == 1 then
		return 'st'
	elseif number == 2 then
		return 'nd'
	elseif number == 3 then
		return 'rd'
	else return 'th'
    end	
end


--[[
-- Retrieves the given color from the settings and returns
-- it as hex color value.
--
-- @param   string   name: The name of the color (e.g. "font")
-- @param   float    fade (optional): This number is multiplied with the alpha
-- 			part of the color, to fade the element the color
-- 			is used with
-- @return  color   A color created with tocolor()
-- ]]
function getColor(name,fade)
	if fade == nil then
		fade = 1
	end
	return tocolor(s(name.."ColorRed"),s(name.."ColorGreen"),s(name.."ColorBlue"),s(name.."ColorAlpha") * fade)
end

--[[
-- Draws text with a background
--
-- @param   string   text: The actual text to be drawn
-- @param   int      x: The upper left corner of the start of the text
-- @param   int      y: The upper left corner of the start of the text
-- @param   color    color: The font color
-- @param   color    backgroundColor: The color used for the background
-- ]]
function drawText(text,x,y,color,backgroundColor)
	x = math.floor(x + 0.5)
	y = math.floor(y + 0.5)
	local font = s("fontType")
	local fontScale = s("fontSize")

	local textWidth = math.floor(dxGetTextWidth(text,fontScale,font))
	local fontHeight = math.floor(dxGetFontHeight(fontScale,font))
	
	local cornerSize = math.floor(fontHeight / 2.5)

	--  TODO: if the font size is made bigger, the borders increase as well,
	--  but the calculation for the space is fixed
	if s("roundCorners") then
		dxDrawRectangle(x,y, textWidth, fontHeight, backgroundColor)

		dxDrawRectangle(x - cornerSize,y + cornerSize, cornerSize, fontHeight - cornerSize*2,backgroundColor)
		dxDrawRectangle(x + textWidth,y + cornerSize, cornerSize, fontHeight - cornerSize*2,backgroundColor)

		dxDrawImage(x - cornerSize, y, cornerSize, cornerSize, "corner.png",0,0,0,backgroundColor)
		dxDrawImage(x - cornerSize, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner.png",270,0,0,backgroundColor)
		dxDrawImage(x + textWidth, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner.png",180,0,0,backgroundColor)
		dxDrawImage(x + textWidth, y, cornerSize, cornerSize, "corner.png",90,0,0,backgroundColor)

		--[[
		dxDrawImage(x - cornerSize - 1, y-1, cornerSize, cornerSize, "corner2.png",0,0,0,tocolor(0,0,0,255))
		dxDrawImage(x - cornerSize, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner2.png",270,0,0,tocolor(0,0,0,255))
		dxDrawImage(x + textWidth, y + fontHeight - cornerSize, cornerSize, cornerSize, "corner2.png",180,0,0,tocolor(0,0,0,255))
		dxDrawImage(x + textWidth, y, cornerSize, cornerSize, "corner2.png",90,0,0,tocolor(0,0,0,255))

		dxDrawLine(x,y-1,x+textWidth,y-1,tocolor(0,0,0,255))
		dxDrawLine(x,y+fontHeight,x+textWidth,y+fontHeight,tocolor(0,0,0,255))
		dxDrawLine(x,y-2,x+textWidth,y-2,tocolor(0,0,0,255))
		dxDrawLine(x,y+fontHeight+1,x+textWidth,y+fontHeight+1,tocolor(0,0,0,255))

		dxDrawLine(x - cornerSize-1,y+cornerSize,x-cornerSize-1,y+fontHeight-cornerSize,tocolor(0,0,0,255))
		dxDrawLine(x + textWidth+cornerSize,y+cornerSize,x+textWidth+cornerSize,y+fontHeight-cornerSize,tocolor(0,0,0,255))
		]]
	else
		dxDrawRectangle(x - cornerSize,y,textWidth + cornerSize*2,fontHeight,backgroundColor)
		--[[
		dxDrawLine(x - cornerSize / 2,y-1,x+textWidth + cornerSize/2,y-1,tocolor(0,0,0,255))
		dxDrawLine(x - cornerSize / 2 - 1,y-1,x-cornerSize/2 - 1,y+fontHeight,tocolor(0,0,0,255))
		dxDrawLine(x - cornerSize / 2,y+fontHeight,x+textWidth + cornerSize/2,y+fontHeight,tocolor(0,0,0,255))
		dxDrawLine(x+textWidth+cornerSize/2,y-1,x+textWidth+cornerSize/2,y+fontHeight,tocolor(0,0,0,255))
		]]
	end
	dxDrawText(text,x,y,x,y,color,fontScale,font)
	--dxDrawText(tostring(y),0,0,0)
end

addEventHandler("onClientScreenFadedOut",getRootElement(),function() screenFadedOut = true end)
addEventHandler("onClientScreenFadedIn",getRootElement(),function() screenFadedOut = false end)

------------------
-- Settings Gui --
------------------

local gui = {}
local radioButtons = {}

--[[
-- This will determine if the settings gui is currently visible.
--
-- @return   boolean   true if the gui exists and is visible, false otherwise
-- ]]
function isGuiVisible()
	if not isElement(gui.window) then
		return false
	end
	return guiGetVisible(gui.window)
end

local function handleEdit(element)
	for k,v in pairs(gui) do
		local _,_,radioName = string.find(k,"radio_(%w+)_%d+")
		if element == v and (settingsObject.settings.default[k] ~= nil or settingsObject.settings.default[radioName] ~= nil) then
			--outputChatBox(tostring(getElementType(element)))
			if type(settingsObject.settings.main[k]) == "boolean" then
				settingsObject:set(k,guiCheckBoxGetSelected(element))
			elseif getElementType(element) == "gui-radiobutton" then
				if guiRadioButtonGetSelected(element) then
					local data = radioButtons[radioName]
					local _,_,key = string.find(k,"radio_%w+_(%d+)")
					settingsObject:set(radioName,data[tonumber(key)].value)
				end
			else
				settingsObject:set(k,guiGetText(element))
			end
		end
	end
	prepareDraw()
end

local function handleClick()

	handleEdit(source)

	if source == gui.buttonSave then
		settingsObject:saveToXml()
	end
	if source == gui.buttonClose then
		closeGui()
	end
end

local function addColor(color,name,top,help)
	local label = guiCreateLabel(24,top,140,20,name..":",false,gui.tabStyles)
	local defaultButton = {}
	gui[color.."Red"] = guiCreateEdit(160,top,50,20,tostring(s(color.."Red")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Red"],value=s(color.."Red","default")})
	gui[color.."Green"] = guiCreateEdit(215,top,50,20,tostring(s(color.."Green")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Green"],value=s(color.."Green","default")})
	gui[color.."Blue"] = guiCreateEdit(270,top,50,20,tostring(s(color.."Blue")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Blue"],value=s(color.."Blue","default")})
	gui[color.."Alpha"] = guiCreateEdit(325,top,50,20,tostring(s(color.."Alpha")),false,gui.tabStyles)
	table.insert(defaultButton,{mode="set",edit=gui[color.."Alpha"],value=s(color.."Alpha","default")})
	addEditButton(390,top,50,20,"default",false,gui.tabStyles,unpack(defaultButton))
	if help ~= nil then
		addHelp(help,label,gui[color.."Red"],gui[color.."Green"],gui[color.."Blue"],gui[color.."Alpha"])
	end
end


--[[
-- This will add one or (usually) several radio-buttons, that can be used
-- to change a single setting.
--
-- @param   int     x: The x position of the buttons
-- @param   int     y: The y position of the first button (others will be placed below)
-- @param   string  name: The name of the radio-button-group with which it will be identified
-- 				and is also the name of the setting these radio-buttons represent
-- @param   table   data: A table of the options to be added, numeric indices, possible elements:
-- 				text: The text of the radio button
-- 				value: The value to be set if the radio button is activated
-- ]]
local function addRadioButtons(x,y,name,data,selected)
	local pos = y
	for k,v in pairs(data) do
		local radio = guiCreateRadioButton(x,pos,200,20,v.text,false,gui.tabGeneral)
		if v.help ~= nil then
			addHelp(v.help,radio)
		end
		gui["radio_"..name.."_"..k] = radio
		if selected == v.value then
			guiRadioButtonSetSelected(radio,true)
		end
		pos = pos + 20
	end
	radioButtons[name] = data
end

--[[
-- Creates all the settings gui elements and either adds them to a window
-- if the "gamecenter" resource is not running or adds them to the "gamecenter" gui.
--
-- If the gui already exists, calling this function will have no effect.
-- ]]
function createGui()
	-- Check if GUI already exists
	if gui.window ~= nil then
		return
	end

	-- Check if "gamecenter" is running and if so, get a srcollpane to add the elements to,
	-- otherwise create a window.
	gamecenterResource = getResourceFromName("gamecenter")

	if gamecenterResource then
		gui.window = call(gamecenterResource,"addWindow","Settings","Race Progress",500,560)
	else
		gui.window = guiCreateWindow ( 320, 240, 500, 560, "Race Progress Bar settings", false )
	end
	
	-- Create the actual elements
	
	-- TABS
	gui.tabs = guiCreateTabPanel(0,24,500,400,false,gui.window)
	gui.tabGeneral = guiCreateTab("General",gui.tabs)
	addHelp("General settings for the progress display.",gui.tabGeneral)
	gui.tabStyles = guiCreateTab("Styles",gui.tabs)
	addHelp("Styling settings.",gui.tabStyles)

	-----------------
	-- TAB GENERAL --
	-----------------
	gui.enabled = guiCreateCheckBox(24,20,100,20,"Enable",s("enabled"),false,gui.tabGeneral)
	addHelp("Show or hide the Progress Bar.",gui.enabled)
	gui.drawDistance = guiCreateCheckBox(180,20,100,20,"Show distance",s("drawDistance"),false,gui.tabGeneral)
	addHelp("If enabled, shows the distances to other players, the total race distance and your own travelled distance on the right-hand side.",gui.drawDistance)
	gui.drawDelay = guiCreateCheckBox(290,20,110,20,"Show time delay",s("drawDelay"),false,gui.tabGeneral)
	addHelp("If enabled, shows the time difference to other players (at checkpoints) on the right-hand side.",gui.drawDelay)

	guiCreateLabel(24,50,70,20,"Size:",false,gui.tabGeneral)
	gui.size = guiCreateEdit(100,50,80,20,tostring(s("size")),false,gui.tabGeneral)
	addHelp("The size (height) of the progress display (relative to screen resolution).",gui.size)
	addEditButton(190,50,60,20,"smaller",false,gui.tabGeneral,{mode="add",edit=gui.size,add=-0.1})
	addEditButton(260,50,60,20,"bigger",false,gui.tabGeneral,{mode="add",edit=gui.size,add=0.1})
	addEditButton(330,50,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.size,value=s("size","default")})

	guiCreateLabel(24,80,80,20,"Font size:",false,gui.tabGeneral)
	gui.fontSize = guiCreateEdit(100,80,80,20,tostring(s("fontSize")),false,gui.tabGeneral)
	addHelp("The size of the text.",gui.fontSize)
	addEditButton(190,80,60,20,"smaller",false,gui.tabGeneral,{mode="add",edit=gui.fontSize,add=-0.1})
	addEditButton(260,80,60,20,"bigger",false,gui.tabGeneral,{mode="add",edit=gui.fontSize,add=0.1})
	addEditButton(330,80,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.fontSize,value=s("fontSize","default")})

	guiCreateLabel(24,110,80,20,"Font type:",false,gui.tabGeneral)
	gui.fontType = guiCreateEdit(100,110,80,20,tostring(s("fontType")),false,gui.tabGeneral)
	addHelp("The font type of the text.",gui.fontType)
	addEditButton(190,110,60,20,"<--",false,gui.tabGeneral,{mode="cyclebackwards",edit=gui.fontType,values=fonts})
	addEditButton(260,110,60,20,"-->",false,gui.tabGeneral,{mode="cycle",edit=gui.fontType,values=fonts})
	addEditButton(330,110,60,20,"default",false,gui.tabGeneral,{mode="set",edit=gui.fontType,value=s("fontType","default")})

	guiCreateLabel(24, 140, 60, 20, "Position:", false, gui.tabGeneral )

	guiCreateLabel(100, 140, 40, 20, "Top:", false, gui.tabGeneral )
	gui.top = guiCreateEdit( 140, 140, 60, 20, tostring(s("top")), false, gui.tabGeneral )
	addHelp("The relative position of the upper left corner of the progress display, from the top border of the screen.",gui.top)

	addEditButton(258, 140, 40, 20, "up", false, gui.tabGeneral, {mode="add",edit=gui.top,add=-0.01})
	addEditButton(258, 166, 40, 20, "down", false, gui.tabGeneral, {mode="add",edit=gui.top,add=0.01})
	
	guiCreateLabel(100, 166, 40, 20, "Left:", false, gui.tabGeneral )
	gui.left = guiCreateEdit( 140, 166, 60, 20, tostring(s("left")), false, gui.tabGeneral )
	addHelp("The relative position of the upper left corner of the progress display, from the left border of the screen.",gui.left)
	addEditButton(210, 166, 40, 20, "left", false, gui.tabGeneral, {mode="add",edit=gui.left,add=-0.01})
	addEditButton( 306, 166, 40, 20, "right", false, gui.tabGeneral, {mode="add",edit=gui.left,add=0.01})
	
	addEditButton(360, 166, 50, 20, "default", false, gui.tabGeneral,
		{mode="set",edit=gui.top,value=s("top","default")},
		{mode="set",edit=gui.left,value=s("left","default")}
	)

	guiCreateLabel(24,200,60,20,"Mode:",false,gui.tabGeneral)
	gui.mode = guiCreateEdit( 100, 200,80,20,tostring(s("mode")),false,gui.tabGeneral)
	local button1 = addEditButton(190,200,80,20,"toggle Mode",false,gui.tabGeneral,{mode="cycle",edit=gui.mode,values={"km","miles"}})
	addHelp("Changes the display of the distances between kilometres or miles.",gui.mode,button1)

	--gui.shufflePlayers = guiCreateCheckBox(24,230,140,20,"Shuffle playernames",s("shufflePlayers"),false,gui.tabGeneral)
	addHelp("Changes the order in which playernames are drawn randomly everytime the data is updated. This will switch between overlapping players, however in an irregular fashion. This will have no effect if the playernames are sorted by length.",gui.shufflePlayers)

	--gui.sortByLength = guiCreateCheckBox(24,256,180,20,"Sort playernames by length",s("sortByLength"),false,gui.tabGeneral)
	addHelp("Sorts the playernames by their length, so short names are drawn on top of long names, which might sometimes make overlapping names better readable. If you have this enabled, shuffling the players will have no effect.",gui.sortByLength)

	gui.preferNear = guiCreateCheckBox(24,300,280,20,"Prefer players behind or in front of you",s("preferNear"),false,gui.tabGeneral)
	addHelp("Draws players directly before or in front of you on top of the other players, so you know who you race against. If you have this enabled, the shuffle or sorting functions have no effect for those players affected by this setting.",gui.preferNear)

	addRadioButtons(24,234,"sortMode",{
		{text="Sort playernames by length",value="length",help="This affects how playernames that are close to eachother overlap. If this option is selected, shorter playernames will be drawn ontop."},
		{text="Shuffle playernames",value="shuffle",help="This affects how playernames that are close to eachother overlap. If this option is selected, the order in which the playernames are drawn changes randomly."},
		{text="Sort playernames by rank",value="rank",help="This affects how playernames that are close to eachother overlap. If this option is selected, playernames of players who have a higher rank are preferred and drawn ontop."}
	},s("sortMode"))

	----------------
	-- TAB STYLES --
	----------------
	
	guiCreateLabel(165,40,40,20,"Red",false,gui.tabStyles)
	guiCreateLabel(220,40,40,20,"Green",false,gui.tabStyles)
	guiCreateLabel(275,40,40,20,"Blue",false,gui.tabStyles)
	guiCreateLabel(325,40,40,20,"Alpha",false,gui.tabStyles)

	addColor("barColor","Bar Color",60,"Background color of the progress bar.")
	addColor("progressColor","Progress",84,"Color of the bar the fills the background depending on your progress.")
	addColor("fontColor","Font",108,"The color of the text, except your own name and distance.")
	addColor("font2Color","Font (yours)",132,"The color of your own name and distance.")
	addColor("backgroundColor","Background",156,"The background color of the text, except your own name and distance.")
	addColor("background2Color","Background (yours)",180,"The background color of your own name and distance.")
	addColor("fontDelayColor","Font (delay)",204,"The font color of the delay times.")
	addColor("backgroundDelayColor","Background (delay)",228,"The background color of the delay times.")
	
	gui.roundCorners = guiCreateCheckBox(24,260,140,20,"Round corners",s("roundCorners"),false,gui.tabStyles)
	addHelp("Use round corners for the background of the text.",gui.roundCorners)

	--------------------
	-- ALWAYS VISIBLE --
	--------------------
	gui.helpMemo = guiCreateMemo(0,440,500,80,"Move your mouse over a GUI Element to get help (if available).",false,gui.window)
	guiHelpMemo = gui.helpMemo

	gui.buttonSave = guiCreateButton( 160, 530, 50, 20, "Save", false, gui.window )
	gui.buttonClose = guiCreateButton( 240, 530, 50, 20, "Close", false, gui.window )

	-- Events and "gamecenter" stuff
	if gamecenterResource then
		guiSetEnabled(gui.buttonClose,false)
	else
		guiSetVisible(gui.window,false)
	end
	addEventHandler("onClientGUIClick",gui.window,handleClick)
	addEventHandler("onClientGUIChanged",gui.window,handleEdit)
	addEventHandler("onClientMouseEnter",gui.window,handleHelp)
end

--[[
-- As soon as the "gamecenter" resource is started, this will create the GUI
-- if it wasn't already (if it is created, it will also be added to the gamecenter gui).
-- ]]
addEventHandler("onClientResourceStart",getRootElement(),
	function(resource)
		if getResourceName(resource) == "gamecenter" then
			-- Create the GUI as soon as the gamecenter-resource starts (if it hasn't been created yet)
			createGui()
			--recreateGui()
		elseif resource == getThisResource() then
			if getResourceFromName("gamecenter") then
				createGui()
			end
		end
	end
)

-- TODO: check if this can somehow work
addEventHandler("onClientResourceStop",getRootElement(),
	function(resource)
		if getResourceName(resource) == "gamecenter" then
			--recreateGui()
		end
	end
)

--[[
-- Destroys all GUI elements of the settings GUI and creates them again.
-- TODO: not working nor used
-- ]]
function recreateGui()
	for k,v in pairs(gui) do
		if isElement(v) then
			outputConsole(getElementType(v).." "..guiGetText(v))
			destroyElement(v)
		end
	end
	gui = {}
	createGui()
end

--[[
-- Opens the GUI, as well as creates it first (if necessary). Will call
-- gamecenter to open the appropriate window if it is running.
-- ]]
function openGui()
	-- Create the GUI as soon as someone tries to open it (if it hasn't been created yet)
	createGui()
	
	if gamecenterResource then
		exports.gamecenter:open("Settings","Race Progress")
	else
		guiSetVisible(gui.window,true)
		showCursor(true)
	end
end

--[[
-- Either hides the window or asks gamecenter to close its gui, if it is running.
-- ]]
function closeGui()
	if gamecenterResource then
		exports.gamecenter:close()
	else
		guiSetVisible(gui.window,false)
		showCursor(false)
	end
end

--[[
-- Shows the gui if it is hidden and vice versa.
-- ]]
function toggleGui()
	if guiGetVisible(gui.window) then
		closeGui()
	else
		openGui()
	end
end

addCommandHandler("progress",toggleGui)

------------------
-- Key Handling --
------------------

local keyDown = 0
local longPress = 300
local keyTimer = nil

--[[
-- Called when a key is pressed/released and checks how long it was pressed
-- as well as starts a timer that will open the gui if necessary.
--
-- @param   string   key: The key that was pressed
-- @param   string   keyState: The state of the key ("up", "down")
-- ]]
-- function keyHandler(key,keyState) -- uncommented by KaliBwoy, added to settings menu
-- 	if keyState == "down" then
-- 		keyDown = getTickCount()
-- 		keyTimer = setTimer(keyTimerHandler,longPress,1)
-- 	else
-- 		-- Key was released, kill timer if it is running
-- 		-- to prevent the GUI from opening
-- 		if isTimer(keyTimer) then
-- 			killTimer(keyTimer)
-- 		end
-- 		-- Calculate the time passed, and if the timer wasn't yet executed,
-- 		-- toggle the progress bar
-- 		local timePassed = getTickCount() - keyDown
-- 		keyDown = 0
-- 		if timePassed < longPress then
-- 			if s("enabled") then
-- 				settingsObject:set("enabled",false)
-- 			else
-- 				settingsObject:set("enabled",true)
-- 			end
-- 		end
-- 	end
-- end
-- function keyTimerHandler()
-- 	toggleGui()
-- end
-- bindKey(toggleSettingsGuiKey,"both",keyHandler)

