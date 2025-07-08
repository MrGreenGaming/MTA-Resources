---
-- Main client file with drawing and calculating.
-- Heavily based on race_progress by driver2
--

-------------------------
-- Initialize Settings --
-------------------------

local gamecenterResource = false
settingsObject = Settings:new(defaultSettings, "settings.xml")

local function s(setting, settingType)
	return settingsObject:get(setting, settingType)
end

----------------
-- Info Texts --
----------------

local keyInfo = InfoText:new()

---------------
-- Variables --
---------------

local screenWidth, screenHeight = guiGetScreenSize()
local x = nil
local y = nil
local h = nil
local readyToDraw = false
local mapLoaded = false
local screenFadedOut = false
local showingPoll = false

local g_CheckpointDistance = {}
local g_CheckpointDistanceSum = {}
local g_players = nil
local g_distanceT = 0
local g_distanceB = 0
local g_TotalDistance = 0
local g_recordedDistances = {}
local g_recordedDistancesForReplay = {}
local g_times = {}

local g_mapPoints = {}
local g_minX = 0
local g_maxX = 0
local g_minY = 0
local g_maxY = 0
local g_dDiff = 0

local g_showGuideLines = false
local g_updateInterval = 200
local g_updateTimer = nil

-- The maximum name width in pixels of all players
local g_maxNameWidth = 0

---------------
-- Constants --
---------------

local c_fonts = { "default", "default-bold", "clear", "arial", "sans", "pricedown", "bankgothic", "diploma", "beckett" }


------------
-- Events --
------------

function initiate()
	-- setAllowOnce() first, so it already works when loading map and preparing to draw
	keyInfo:setAllowOnce()

	settingsObject:loadFromXml()
	mapStarted()
	startTimer()
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), initiate)

function mapStarted()
	-- Start under the assumption that no checkpoints are found,
	-- so not ready to draw (also the new data hasn't been loaded
	-- yet)
	readyToDraw = false
	mapLoaded = false
	if loadMap() then
		-- If data was successfully loaded, prepare drawing
		mapLoaded = true
		plotMapPoints()
		prepareDraw()
	end
	-- TODO: load saved plots for map
	-- g_recordedDistancesForReplay = g_recordedDistances
	-- g_recordedDistances = {}
	-- g_replayCount = 0
end

addEventHandler("onClientMapStarting", getRootElement(), mapStarted)

function startTimer()
	if (g_updateTimer) then
		killTimer(g_updateTimer)
		g_updateTimer = nil
	end

	g_updateInterval = math.max(s("updateinterval") * 1000, 0)

	g_updateTimer = setTimer(update, g_updateInterval, 0)
end

-------------------------------
-- Load and prepare map data --
-------------------------------

function loadMap()
	--local res = call(getResourceFromName("mapmanager"),"getRunningGamemodeMap")
	-- Get the data or empty tables, if none of these elements exist
	g_Spawnpoints = getAll("spawnpoint")
	g_Checkpoints = sortCheckpoints(getAll("checkpoint"))

	if #g_Spawnpoints > 0 and #g_Checkpoints > 0 then
		return true
	end
	return false
end

function getAll(name)
	local result = {}
	for i, element in ipairs(getElementsByType(name)) do
		result[i] = {}
		result[i].id = getElementID(element)
		result[i].nextid = getElementData(element, "nextid")
		local position = {
			tonumber(getElementData(element, "posX")),
			tonumber(getElementData(element, "posY")),
			tonumber(getElementData(element, "posZ"))
		}
		result[i].position = position
	end
	return result
end

--[[
-- Start with the first checkpoint, then find the first "nextid" for each one. This has
-- to be done since the order of the checkpoints in the file may not be as they are
-- actually connected.
--
-- Checkpoints (except for the first) that aren't referred to by "nextid" are ignored.
--
-- Modifies the argument table.
--
-- @param   table  cps: List of checkpoints, ordered as received from MTA
-- @return  table       Properly ordered list of checkpoints
-- ]]
function sortCheckpoints(cps)
	-- sort checkpoints
	local chains = {} -- a chain is a list of checkpoints that immediately follow each other
	local prevchainnum, chainnum, nextchainnum
	for i, checkpoint in ipairs(cps) do
		-- any chain we can place this checkpoint after?
		chainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
		if chainnum then
			table.insert(chains[chainnum], checkpoint)
			if checkpoint.nextid then
				nextchainnum = table.find(chains, 1, 'id', checkpoint.nextid)
				if nextchainnum then
					table.merge(chains[chainnum], chains[nextchainnum])
					table.remove(chains, nextchainnum)
				end
			end
		elseif checkpoint.nextid then
			-- any chain we can place it before?
			chainnum = table.find(chains, 1, 'id', checkpoint.nextid)
			if chainnum then
				table.insert(chains[chainnum], 1, checkpoint)
				prevchainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
				if prevchainnum then
					table.merge(chains[prevchainnum], chains[chainnum])
					table.remove(chains, chainnum)
				end
			else
				-- new chain
				table.insert(chains, { checkpoint })
			end
		else
			table.insert(chains, { checkpoint })
		end
	end
	return chains[1] or {}
end

--[[
-- Calculate and store line coordinates based on checkpoint coordinates (as well as one spawnpoint),
-- for use of drawing the map.
--
-- g_scalePoints: Points used for calculating the desired scale of the map, but not actually drawn
-- g_mapPoints: Points used for drawing the map
--
-- ]]
function plotMapPoints()
	-- First we will plot all the points, regardless of map size.
	-- We do this first so it is easier to add a potential 3D effect for height in the future
	g_scalePoints = {}
	g_mapPoints = {}
	g_minX = math.huge
	g_maxX = math.huge * -1
	g_minY = math.huge
	g_maxY = math.huge * -1
	g_dDiff = 0

	for k, v in ipairs(g_Spawnpoints) do
		table.insert(g_scalePoints, { v.position[1], v.position[2] })
		if (k == 1) then
			table.insert(g_mapPoints, { v.position[1], v.position[2] })
		end
	end
	for k, v in ipairs(g_Checkpoints) do
		table.insert(g_scalePoints, { v.position[1], v.position[2] })
		table.insert(g_mapPoints, { v.position[1], v.position[2] })
	end
	for k, v in ipairs(g_scalePoints) do
		if (v[1] < g_minX) then g_minX = v[1] end
		if (v[1] > g_maxX) then g_maxX = v[1] end
		if (v[2] < g_minY) then g_minY = v[2] end
		if (v[2] > g_maxY) then g_maxY = v[2] end
	end
	-- Get the difference between all the points
	local xDiff = g_maxX - g_minX
	local yDiff = g_maxY - g_minY
	local dDiff = math.max(xDiff, yDiff) -- We want to use the larger of the two to prevent either one from leaving the bounding box
	if (dDiff == 0) then
		-- All checkpoints are perfectly vertical
		g_minX = -3000
		g_minY = -3000
		g_maxX = 3000
		g_maxY = 3000
	else
		-- Add some padding
		g_minX = g_minX - (dDiff * 0.02)
		g_minY = g_minY - (dDiff * 0.02)
		g_maxX = g_maxX + (dDiff * 0.02)
		g_maxY = g_maxY + (dDiff * 0.02)
	end
	local xDiff = g_maxX - g_minX
	local yDiff = g_maxY - g_minY
	g_dDiff = math.max(xDiff, yDiff)

	-- Scale to screen size & settings
	g_top = math.floor(s("top") * screenHeight)
	g_left = math.floor(s("left") * screenWidth)
	g_size = math.floor(s("size") * screenHeight)

	for k, v in ipairs(g_mapPoints) do
		local x = v[1]
		local y = v[2]
		-- Anchor to 0,0
		x = x - g_minX
		y = y - g_minY
		-- Scale to 0-1
		x = x / g_dDiff
		y = y / g_dDiff
		-- Scale up to desired scale
		x = x * g_size
		y = y * g_size
		-- Flip y
		y = g_size - y
		-- Add screen offsets
		x = x + g_left
		y = y + g_top
		v[1] = x
		v[2] = y
	end
end

----------------------------
-- Update player position --
----------------------------

function update()
	-- If not checkpoints are present on the current map,
	-- we don't need to do anything.
	if not mapLoaded or not s("enabled") then
		return
	end

	-- Start with an empty table, this way players
	-- won't have to be removed, but simply not added
	g_players = {}
	g_localPlayerPosition = nil
	g_localPlayerColor = nil

	-- Go through all current players
	for pi, player in ipairs(getElementsByType("player")) do
		if (not getElementData(player, "race.finished") and getElementData(player, "state") == "alive") then
			local vehicle = getPedOccupiedVehicle(player)
			if (vehicle) then
				local x, y, z = getElementPosition(vehicle)
				if (x + 20 > g_minX and x - 20 < g_maxX and y + 20 > g_minY and y - 20 < g_maxY) then
					-- Anchor to 0,0
					x = x - g_minX
					y = y - g_minY
					-- Scale to 0-1
					x = x / g_dDiff
					y = y / g_dDiff
					-- Scale up to desired scale
					x = x * g_size
					y = y * g_size
					-- Flip y
					y = g_size - y
					-- Add screen offsets
					x = x + g_left
					y = y + g_top
					-- other player info
					local r, g, b, _, _, _, _, _, _, _, _, _ = getVehicleColor(vehicle, true)
					local playerName = stripColors(getPlayerName(player))
					if getPlayerTeam(player) then
						local teamR, teamG, teamB = getTeamColor(getPlayerTeam(player))
						if (teamR and teamG and teamB) then
							r, g, b = teamR, teamG, teamB
						end
					end
					-- Add with numeric index to make shuffling possible
					table.insert(g_players, { playerName, player, x, y, r, g, b })
					-- Save Local Player info separately
					if player == getLocalPlayer() then
						g_localPlayerName = playerName
						g_localPlayerPosition = { x, y }
						g_localPlayerColor = { r, g, b }
					end
				end
			end
		end
	end

	-- Test players
	--table.insert(players,{"Start",0})
	--table.insert(players,{"Start2",10})
	--table.insert(players,{"a",700})
	--table.insert(players,{"b",1100})	
	--table.insert(players,{"c",1100})
	--table.insert(players,{"d",1100})
	--table.insert(players,{"e",1100})
	--table.insert(players,{"f",1100})
	--table.insert(players,{"g",1100})
	--table.insert(players,{"norby890",32})
	--table.insert(players,{"AdnanKananda",110})
	--table.insert(players,{"Player234",500})
	--table.insert(players,{"Kray-Z",1050})
	--table.insert(players,{"SneakyViper",1100})
	--table.insert(players,{"100", 100})
	--table.insert(players,{"600", 600})
	--table.insert(players,{"1000", 1000})
	--table.insert(players,{"1500", 1500})
	--if g_localPlayerDistance ~= nil then
	--	for i=-10,10,1 do
	--		local d = g_localPlayerDistance + i*73
	--		table.insert(players,{tostring(d), d})
	--	end
	--end

	-- Just put all players into the middle section
	sortPlayers(g_players)


	checkKeyInfo()
end

--[[
-- Sort the players, if enabled.
-- ]]
function sortPlayers(players)
	if s("sortMode") == "length" then
		table.sort(players, function(w1, w2) if w1[1]:len() > w2[1]:len() then return true end end)
	elseif s("sortMode") == "shuffle" then
		shuffle(players)
	elseif s("sortMode") == "rank" then
		table.sort(players, function(w1, w2) if w1[2] < w2[2] then return true end end)
	end

	-- Prefer players directly in front and behind you if enabled
	if s("preferNear") and g_localPlayerDistance ~= nil then
		local prevNick = nil
		local playerBefore = nil
		local playerAfter = nil
		local playerBeforeKey = 0
		local playerAfterKey = 0
		for key, table in pairs(players) do
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
			table.insert(players, table.remove(players, playerAfterKey))
			-- Correct the index if needed (because the indices may have shifted,
			-- which would cause the playerBeforeKey not to be correct anymore)
			if playerBeforeKey > 0 then
				playerBeforeKey = playerBeforeKey - 1
			end
		end
		if playerBeforeKey ~= 0 then
			table.insert(players, table.remove(players, playerBeforeKey))
		end
	end
end

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

--[[
-- Calculate the distance from the given player position to the
-- checkpoint at the given index.
--
-- @param   player  player: The player object
-- @param   number  index:  The checkpoint index
-- @return  number          The distance of the player to the checkpoint
-- ]]
function distanceFromPlayerToCheckpoint(player, index)
	-- TODO: check if the index exists
	local checkpoint = g_Checkpoints[index]
	if checkpoint == nil then
		return false
	end
	local x, y, z = getElementPosition(player)
	return getDistanceBetweenPoints3D(x, y, z, unpack(checkpoint.position))
end

-------------
-- Drawing --
-------------

--[[
-- Sets stuff needed for drawing that only changes when the map changes or
-- when settings change. Thus, this is only called if necessary, not on
-- every frame.
-- ]]
function prepareDraw()
	-- Map needs to be loaded, a lot depends on it
	if not mapLoaded then
		return
	end

	-- Variables that stay the same (until settings are changed)

	-- Colors
	s_lineColor = getColor("line")
	s_shadowColor = getColor("shadow")

	checkKeyInfo()

	update()

	-- Ready preparing, can start drawing if necessary
	readyToDraw = true
end

--[[
-- This actually draws all the stuff on the screen.
--
-- ]]
function draw()
	-- Check if drawing is enabled
	if not readyToDraw or not s("enabled") or screenFadedOut or showingPoll or g_players == nil then
		return
	end

	-- Draw Info Texts (will only actually draw if currently shown)
	keyInfo:draw()

	g_maxNameWidth = 0

	drawMap()
end

-- Keep track of the players' avatars, so we can draw them on the map
local playerAvatars = {}
addEventHandler("onClientMapStarting", root, function()
	for id, player in ipairs(getElementsByType("player")) do
		if not playerAvatars[player] and isElement(player) and getElementData(player, "forumAvatar") and getElementData(player, "forumAvatar").src ~= ":stats/images/avatar.png" then
			local texture = dxCreateTexture(getElementData(player, "forumAvatar").src)
			if texture then
				playerAvatars[player] = texture
			end
		end
	end
end)

addEventHandler("onClientPlayerQuit", root, function()
	if playerAvatars[source] then
		destroyElement(playerAvatars[source])
		playerAvatars[source] = nil
	end
end)

--[[
-- This actually draws all the stuff on the screen.
-- ]]
function drawMap()
	for k, v in ipairs(g_mapPoints) do
		if (k > 1) then
			w = g_mapPoints[k - 1]
			if (w[1] ~= v[1] or w[2] ~= v[2]) then
				dxDrawLine(w[1] + 3, w[2] + 3, v[1] + 3, v[2] + 3, s_shadowColor, 5)
			else
				dxDrawCircle(w[1] + 3, w[2] + 3, 5, 0.0, 360.0, s_shadowColor, s_shadowColor, 8)
			end
		end
	end
	for k, v in ipairs(g_mapPoints) do
		if (k > 1) then
			w = g_mapPoints[k - 1]
			if (w[1] ~= v[1] or w[2] ~= v[2]) then
				dxDrawLine(w[1], w[2], v[1], v[2], s_lineColor, 3)
			else
				dxDrawCircle(w[1], w[2], 5, 0.0, 360.0, s_lineColor, s_lineColor, 8)
			end
		end
	end
	-- Guidelines/bounding box:
	if (g_showGuideLines) then
		dxDrawLine(g_left, g_top, g_left + g_size, g_top, tocolor(255, 0, 255))
		dxDrawLine(g_left, g_top, g_left, g_top + g_size, tocolor(255, 0, 255))
		dxDrawLine(g_left + g_size, g_top, g_left + g_size, g_top + g_size, tocolor(255, 0, 255))
		dxDrawLine(g_left + g_size, g_top + g_size, g_left, g_top + g_size, tocolor(255, 0, 255))
	end

	----------------------
	-- Draw all players --
	----------------------
	-- Local player gets a bigger dot, put them on the background so it doesn't cover up close competitors
	local localPlayerValue = nil
	for _, value in pairs(g_players) do
		if value[2] == getLocalPlayer() then
			localPlayerValue = value
		end
	end
	if localPlayerValue then
		-- local localPlayerName = localPlayerValue[1]
		-- local localPlayerElement = localPlayerValue[2]
		local localPlayerX = localPlayerValue[3]
		local localPlayerY = localPlayerValue[4]
		local localPlayerColor = tocolor(localPlayerValue[5], localPlayerValue[6], localPlayerValue[7], 245)
		if playerAvatars[localPlayer] then
			dxDrawImage(localPlayerX - 10, localPlayerY - 10, 20, 20, playerAvatars[localPlayer])
		else
			dxDrawCircle(localPlayerX, localPlayerY, 12, 0.0, 360.0, tocolor(0, 0, 0, 220), tocolor(0, 0, 0, 220), 32)
			dxDrawCircle(localPlayerX, localPlayerY, 10, 0.0, 360.0, tocolor(220, 220, 220, 220), tocolor(220, 220, 220, 220),
				32)
			dxDrawCircle(localPlayerX, localPlayerY, 8, 0.0, 360.0, localPlayerColor, localPlayerColor, 32)
		end
	end

	for pos, value in pairs(g_players) do
		-- local playerName = value[1]
		local playerElement = value[2]
		local playerX = value[3]
		local playerY = value[4]
		local playerColor = tocolor(value[5], value[6], value[7], 245)
		if playerElement ~= getLocalPlayer() then
			if playerAvatars[playerElement] then
				dxDrawImage(playerX - 8, playerY - 8, 16, 16, playerAvatars[playerElement])
			else
				dxDrawCircle(playerX, playerY, 7, 0.0, 360.0, tocolor(0, 0, 0, 220), tocolor(0, 0, 0, 220), 32)
				dxDrawCircle(playerX, playerY, 6, 0.0, 360.0, tocolor(220, 220, 220, 220), tocolor(220, 220, 220, 220), 32)
				dxDrawCircle(playerX, playerY, 5, 0.0, 360.0, playerColor, playerColor, 32)
			end
		end
	end
end

addEventHandler("onClientRender", getRootElement(), draw)

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
function getColor(name, fade)
	if fade == nil then
		fade = 1
	end
	return tocolor(s(name .. "ColorRed"), s(name .. "ColorGreen"), s(name .. "ColorBlue"), s(name .. "ColorAlpha") * fade)
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
function drawText(text, x, y, color, backgroundColor, left)
	local font = "clear"
	local fontScale = 1

	local textWidth = math.floor(dxGetTextWidth(text, fontScale, font))
	local fontHeight = math.floor(dxGetFontHeight(fontScale, font))

	x = math.floor(x + 20)
	y = math.floor(y)

	local cornerSize = math.floor(fontHeight / 5)

	dxDrawRectangle(x - cornerSize, y - cornerSize, textWidth + cornerSize * 2, fontHeight + cornerSize * 2,
		backgroundColor)
	dxDrawText(text, x, y, x + 22, y + 22, color, fontScale, font)
	--dxDrawText(tostring(y),0,0,0)
end

addEventHandler("onClientScreenFadedOut", getRootElement(), function() screenFadedOut = true end)
addEventHandler("onClientScreenFadedIn", getRootElement(), function() screenFadedOut = false end)

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
	if element == gui.helpMemo then
		return
	end

	for k, v in pairs(gui) do
		local _, _, radioName = string.find(k, "radio_(%w+)_%d+")
		if element == v and (settingsObject.settings.default[k] ~= nil or settingsObject.settings.default[radioName] ~= nil) then
			--outputChatBox(tostring(getElementType(element)))
			if type(settingsObject.settings.main[k]) == "boolean" then
				settingsObject:set(k, guiCheckBoxGetSelected(element))
			elseif getElementType(element) == "gui-radiobutton" then
				if guiRadioButtonGetSelected(element) then
					local data = radioButtons[radioName]
					local _, _, key = string.find(k, "radio_%w+_(%d+)")
					settingsObject:set(radioName, data[tonumber(key)].value)
				end
			else
				settingsObject:set(k, guiGetText(element))
			end
		end
	end
	startTimer()
	plotMapPoints()
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

local function addColor(color, name, top, help)
	local label = guiCreateLabel(24, top, 140, 20, name .. ":", false, gui.tabStyles)
	local defaultButton = {}
	gui[color .. "Red"] = guiCreateEdit(160, top, 50, 20, tostring(s(color .. "Red")), false, gui.tabStyles)
	table.insert(defaultButton, { mode = "set", edit = gui[color .. "Red"], value = s(color .. "Red", "default") })
	gui[color .. "Green"] = guiCreateEdit(215, top, 50, 20, tostring(s(color .. "Green")), false, gui.tabStyles)
	table.insert(defaultButton, { mode = "set", edit = gui[color .. "Green"], value = s(color .. "Green", "default") })
	gui[color .. "Blue"] = guiCreateEdit(270, top, 50, 20, tostring(s(color .. "Blue")), false, gui.tabStyles)
	table.insert(defaultButton, { mode = "set", edit = gui[color .. "Blue"], value = s(color .. "Blue", "default") })
	gui[color .. "Alpha"] = guiCreateEdit(325, top, 50, 20, tostring(s(color .. "Alpha")), false, gui.tabStyles)
	table.insert(defaultButton, { mode = "set", edit = gui[color .. "Alpha"], value = s(color .. "Alpha", "default") })
	addEditButton(390, top, 50, 20, "default", false, gui.tabStyles, unpack(defaultButton))
	if help ~= nil then
		addHelp(help, label, gui[color .. "Red"], gui[color .. "Green"], gui[color .. "Blue"], gui[color .. "Alpha"])
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
local function addRadioButtons(x, y, name, data, selected)
	local pos = y
	for k, v in pairs(data) do
		local radio = guiCreateRadioButton(x, pos, 200, 20, v.text, false, gui.tabGeneral)
		if v.help ~= nil then
			addHelp(v.help, radio)
		end
		gui["radio_" .. name .. "_" .. k] = radio
		if selected == v.value then
			guiRadioButtonSetSelected(radio, true)
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
		gui.window = call(gamecenterResource, "addWindow", "Settings", "Race Minimap", 500, 560)
	else
		gui.window = guiCreateWindow(320, 240, 500, 560, "Race Minimap settings", false)
	end

	-- Create the actual elements

	-- TABS
	gui.tabs = guiCreateTabPanel(0, 24, 500, 400, false, gui.window)
	gui.tabGeneral = guiCreateTab("General", gui.tabs)
	addHelp("General settings for the minimap.", gui.tabGeneral)
	gui.tabStyles = guiCreateTab("Styles", gui.tabs)
	addHelp("Styling settings.", gui.tabStyles)
	gui.tabHelp = guiCreateTab("Help", gui.tabs)

	-----------------
	-- TAB GENERAL --
	-----------------
	gui.enabled = guiCreateCheckBox(24, 20, 100, 20, "Enable", s("enabled"), false, gui.tabGeneral)
	addHelp("Show or hide the Minimap.", gui.enabled)

	gui.size = guiCreateEdit(100, 50, 80, 20, tostring(s("size")), false, gui.tabGeneral)
	addHelp("The size (height) of the minimap (relative to screen resolution).", gui.size,
		guiCreateLabel(24, 50, 70, 20, "Size:", false, gui.tabGeneral))
	addEditButton(190, 50, 60, 20, "smaller", false, gui.tabGeneral, { mode = "add", edit = gui.size, add = -0.01 })
	addEditButton(260, 50, 60, 20, "bigger", false, gui.tabGeneral, { mode = "add", edit = gui.size, add = 0.01 })
	addEditButton(330, 50, 60, 20, "default", false, gui.tabGeneral, {
		mode = "set",
		edit = gui.size,
		value = s("size",
			"default")
	})

	guiCreateLabel(24, 140, 60, 20, "Position:", false, gui.tabGeneral)

	gui.top = guiCreateEdit(140, 140, 60, 20, tostring(s("top")), false, gui.tabGeneral)
	addHelp("The relative position of the upper left corner of the minimap, from the top border of the screen.", gui.top,
		guiCreateLabel(100, 140, 40, 20, "Top:", false, gui.tabGeneral))

	addEditButton(258, 140, 40, 20, "up", false, gui.tabGeneral, { mode = "add", edit = gui.top, add = -0.01 })
	addEditButton(258, 166, 40, 20, "down", false, gui.tabGeneral, { mode = "add", edit = gui.top, add = 0.01 })

	gui.left = guiCreateEdit(140, 166, 60, 20, tostring(s("left")), false, gui.tabGeneral)
	addHelp("The relative position of the upper left corner of the minimap, from the left border of the screen.", gui.left,
		guiCreateLabel(100, 166, 40, 20, "Left:", false, gui.tabGeneral))
	addEditButton(210, 166, 40, 20, "left", false, gui.tabGeneral, { mode = "add", edit = gui.left, add = -0.01 })
	addEditButton(306, 166, 40, 20, "right", false, gui.tabGeneral, { mode = "add", edit = gui.left, add = 0.01 })

	addEditButton(360, 166, 50, 20, "default", false, gui.tabGeneral,
		{ mode = "set", edit = gui.top, value = s("top", "default") },
		{ mode = "set", edit = gui.left, value = s("left", "default") }
	)


	gui.updateinterval = guiCreateEdit(120, 240, 80, 20, tostring(s("updateinterval")), false, gui.tabGeneral)
	addHelp("How often to refresh the position of each dot, in seconds.", gui.updateinterval,
		guiCreateLabel(24, 240, 100, 20, "Update Interval:", false, gui.tabGeneral))
	addEditButton(210, 240, 60, 20, "smaller", false, gui.tabGeneral,
		{ mode = "add", edit = gui.updateinterval, add = -0.1 })
	addEditButton(280, 240, 60, 20, "bigger", false, gui.tabGeneral, { mode = "add", edit = gui.updateinterval, add = 0.1 })
	addEditButton(350, 240, 60, 20, "default", false, gui.tabGeneral,
		{ mode = "set", edit = gui.updateinterval, value = s("updateinterval", "default") })

	-- gui.preferNear = guiCreateCheckBox(24,300,280,20,"Prefer players behind or in front of you",s("preferNear"),false,gui.tabGeneral)
	-- addHelp("Draws players directly before or in front of you on top of the other players, so you know who you race against. If you have this enabled, the shuffle or sorting functions have no effect for those players affected by this setting.",gui.preferNear)

	-- addRadioButtons(24,234,"sortMode",{
	-- 	{text="Sort playernames by length",value="length",help="This affects how playernames that are close to eachother overlap. If this option is selected, shorter playernames will be drawn ontop."},
	-- 	{text="Shuffle playernames",value="shuffle",help="This affects how playernames that are close to eachother overlap. If this option is selected, the order in which the playernames are drawn changes randomly."},
	-- 	{text="Sort playernames by rank",value="rank",help="This affects how playernames that are close to eachother overlap. If this option is selected, playernames of players who have a higher rank are preferred and drawn ontop."}
	-- },s("sortMode"))

	----------------
	-- TAB STYLES --
	----------------

	guiCreateLabel(165, 40, 40, 20, "Red", false, gui.tabStyles)
	guiCreateLabel(220, 40, 40, 20, "Green", false, gui.tabStyles)
	guiCreateLabel(275, 40, 40, 20, "Blue", false, gui.tabStyles)
	guiCreateLabel(325, 40, 40, 20, "Alpha", false, gui.tabStyles)

	addColor("lineColor", "Line Color", 60, "Color of the track line.")
	addColor("shadowColor", "Shadow Color", 84, "Colored of the track line's drop shadow.")
	-- addColor("barColor","Bar Color",60,"Background color of the progress bar.")
	-- addColor("progressColor","Progress",84,"Color of the bar the fills the background depending on your progress.")
	-- addColor("fontColor","Font",108,"The color of the text, except your own name and distance.")
	-- addColor("font2Color","Font (yours)",132,"The color of your own name and distance.")
	-- addColor("backgroundColor","Background",156,"The background color of the text, except your own name and distance.")
	-- addColor("background2Color","Background (yours)",180,"The background color of your own name and distance.")
	-- addColor("fontDelayColor","Font (delay)",204,"The font color of the delay times.")
	-- addColor("backgroundDelayColor","Background (delay)",228,"The background color of the delay times.")

	--------------
	-- TAB HELP --
	--------------

	local helpText = xmlNodeGetValue(getResourceConfig("help.xml"))
	gui.helpTextMemo = guiCreateMemo(.05, .05, .9, .9, helpText, true, gui.tabHelp)
	guiMemoSetReadOnly(gui.helpTextMemo, true)

	--------------------
	-- ALWAYS VISIBLE --
	--------------------
	gui.helpMemo = guiCreateMemo(0, 440, 500, 80, "[Move over GUI to get help]", false, gui.window)
	guiHelpMemo = gui.helpMemo

	gui.buttonSave = guiCreateButton(0, 530, 260, 20, "Save Settings To File", false, gui.window)
	addHelp("Saves current settings to file, so that they persist when you reconnect.", gui.buttonSave)
	gui.buttonClose = guiCreateButton(280, 530, 235, 20, "Close", false, gui.window)

	-- Events and "gamecenter" stuff
	if gamecenterResource then
		guiSetEnabled(gui.buttonClose, false)
	else
		guiSetVisible(gui.window, false)
		g_showGuideLines = false
	end
	addEventHandler("onClientGUIClick", gui.window, handleClick)
	addEventHandler("onClientGUIChanged", gui.window, handleEdit)
	addEventHandler("onClientMouseEnter", gui.window, handleHelp)
end

--[[
-- As soon as the "gamecenter" resource is started, this will create the GUI
-- if it wasn't already (if it is created, it will also be added to the gamecenter gui).
-- ]]
addEventHandler("onClientResourceStart", getRootElement(),
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
addEventHandler("onClientResourceStop", getRootElement(),
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
	for k, v in pairs(gui) do
		if isElement(v) then
			outputConsole(getElementType(v) .. " " .. guiGetText(v))
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
	checkKeyInfo(true) -- Also changes title

	if gamecenterResource then
		exports.gamecenter:open("Settings", "Race Minimap")
	else
		guiSetVisible(gui.window, true)
		showCursor(true)
		g_showGuideLines = true
	end
end

--[[
-- Either hides the window or asks gamecenter to close its gui, if it is running.
-- ]]
function closeGui()
	if gamecenterResource then
		exports.gamecenter:close()
	else
		guiSetVisible(gui.window, false)
		showCursor(false)
		g_showGuideLines = false
	end
end

--------------
-- Commands --
--------------

--[[
-- Shows the gui if it is hidden and vice versa.
-- ]]
function toggleGui()
	if gui.window ~= nil and guiGetVisible(gui.window) then
		closeGui()
	else
		openGui()
	end
end

addCommandHandler("minimap", toggleGui)

function toggleBooleanSetting(element, name)
	settingsObject:set(name, not s(name))
	if element ~= nil then
		guiCheckBoxSetSelected(element, s(name))
	end
	startTimer()
	plotMapPoints()
	prepareDraw()
end

function toggleEnabled()
	toggleBooleanSetting(gui.enabled, "enabled")
end

addCommandHandler("minimap_toggle", toggleEnabled)

------------------
-- Key Handling --
------------------

function checkKeyInfo(force)
	keyInfo:showIfAllowed()
end

keyInfo.drawFunction = function(fade)
	drawText("Use /minimap to disable or to modify minimap settings.", g_left, g_top + g_size + 5, tocolor(255, 255, 255),
		tocolor(0, 0, 0, 120), true)
end
