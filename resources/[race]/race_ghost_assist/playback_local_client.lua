g_Root = getRootElement()

-- // =====================[ important variables ] ===================//

-- TODO: TOO MANY UNUSED VARS, BUT BAD CONCURRENCES CAN HAPPEN (node1, node1, prev ..)

local nextNode = nil -- !!!
local node, prev, curr
local node1, node2

local id, idx
local x, y, z
local rx, ry, rz
local fx, fy, fz, gz
local vx, vy, vz

local ghost_speed
local my_speed
local my_dst

local prev_dst = math.huge
local dst = 0
	
local vehicle
local vType
-- local theType
local color_r, color_g, color_b, color_a

local my_weight = 1500
local arrowSize = 2


local lastNodeID = 1 -- gotta start at 1
local nextNodeID = 1 -- gotta start at 1
local drawRacingLine_HANDLER = nil
local assistTimer = nil
local recording = nil

local img = dxCreateTexture("arrow.png")

-- ghost assist thing object
local assist = nil
local assistEnabled = false -- disabled by default
---------------------------------------------------


-- // =============================[ racing lines toggle on/off ] ============================================//
function assistToggle(player, mode)
	mode = tonumber(mode)

-- TODO: TIMER ALWAYS RESUMES IT

	-- assist on/off
	if mode == 1 then
		outputChatBox("* Racing assist enabled.", 230, 220, 180)
		assistEnabled = true
		if recording then show() end
	elseif mode == 0 then
		outputChatBox("* Racing assist disabled.", 230, 220, 180)
		assistEnabled = false
		if recording then hide() end
	end
	
	outputDebug("racing assist: ".. inspect(assistEnabled)) -- DEBUG
	
end -- assistToggle
addCommandHandler('assist', assistToggle)



-- // =============================[ resume/show ] ============================================//
-- TODO: notice here
-- show the racing line
function show()
	if not drawRacingLine_HANDLER then
		drawRacingLine_HANDLER = function() drawRacingLine() end
		addEventHandler("onClientPreRender", g_Root, drawRacingLine_HANDLER)	
		-- outputDebug("Racingline showing")
	end
end

-- // =============================[ hide ] ============================================//
-- hide the racing line for planes/when too far
function hide()
	if drawRacingLine_HANDLER then
		removeEventHandler("onClientPreRender", g_Root, drawRacingLine_HANDLER) 
		drawRacingLine_HANDLER = nil 
		-- outputDebug("Racingline hidden")
	end
end

-- // =============================[ destroy ] ============================================//
function destroy()
	if drawRacingLine_HANDLER then 
		removeEventHandler("onClientPreRender", g_Root, drawRacingLine_HANDLER) 
		drawRacingLine_HANDLER = nil 
		outputDebug("Racingline destroyed")
	end

	if isTimer(assistTimer) then killTimer(assistTimer) end -- must have
	
	recording = nil
end
-- cleanup at finish/map change			
addEventHandler("onClientResourceStart", getRootElement(),
    function()
		if startedRes == "race_ghost_assist" then
			outputDebug("onClientResourceStart")
			addEventHandler("onClientPlayerFinish", g_Root, destroy)	
			addEventHandler("onClientMapStopping", g_Root, destroy)
		end
    end
)



-- // =============================[ load ghost ] ============================================//
function loadGhost(mapName)
	-- local res = getResourceFromName("race_ghost")
	
	-- local ghosts are in the "race_ghost" resource!!!
	local ghost = xmlLoadFile(":race_ghost/ghosts/" .. mapName .. ".ghost")
	outputDebug("@loadGhost: " .. inspect(ghost)) -- DEBUG
	
	if ghost then
		
		-- Construct a table
		local index = 0
		local node = xmlFindChild(ghost, "n", index)
		local recording = {}
		
		while (node) do
			if type(node) ~= "userdata" then
				outputDebugString("race_ghost - playback_local_client.lua: Invalid node data while loading ghost: " .. type(node) .. ":" .. tostring(node), 1)
				break
			end
			
			local attributes = xmlNodeGetAttributes(node)
			local row = {}
			for k, v in pairs(attributes) do
				row[k] = convert(v)	
			end
			
			-- !!!
			-- we only need "po" data
			if (row.ty == "po") then
				table.insert(recording, row)
				-- outputDebug("row: " .. inspect(row)) -- DEBUG
			end

			index = index + 1
			node = xmlFindChild(ghost, "n", index)
		end -- while
		
		-- outputDebug("Found a valid local ghost for " .. mapName)
		-- outputDebug("ghost loaded " .. mapName)

		-- Retrieve info about the ghost
		-- local info = xmlFindChild(ghost, "i", 0)
		-- outputChatBox("* Race assist loaded. (" ..xmlNodeGetAttribute(info, "r").. ") " ..FormatDate(xmlNodeGetAttribute(info, "timestamp")), 0, 255, 0)
		-- outputChatBox("* Race assist loaded.", 0, 255, 0)

		xmlUnloadFile(ghost)
		return recording
	else
		outputDebug("loading ghost failed") -- DEBUG
		-- outputChatBox("* Race assist: you have no ghost for this map.", 0, 255, 0)
		return false
	end -- ghost
	
end -- loadGhost



-- // =============================[ create and prepare, onClientMapStarting ] ============================================//
addEventHandler("onClientMapStarting", g_Root,
	function (mapInfo)
		outputDebug("onClientMapStarting") -- DEBUG
		-- outputDebug("mapInfo: " .. inspect(mapInfo)) -- DEBUG
		
		-- !!!
		if assistEnabled then
			-- destroy any leftover ghosts
			if recording then
				destroy()
			end
		
			-- !!! 
			recording = loadGhost(mapInfo.resname)
			-- !!!
			
			-- ghost was read successfully
			if recording then
				outputDebug("ghost loaded, starting assist") -- DEBUG
				
				lastNodeID = 1 
				nextNodeID = 1
				-- !!!
				-- start a assistTimer that updates raceline parameters
				assistTimer = setTimer(updateRacingLine, 100, 0)
				
				-- show racing line at race start
				show()
			end
			
		end -- assistEnabled
	end -- function
)


-- // =============================[ convert ] ============================================//
function convert(value)
	if tonumber(value) ~= nil then
		return tonumber(value)
	else
		if tostring(value) == "true" then
			return true
		elseif tostring(value) == "false" then
			return false
		else
			return tostring(value)
		end
	end
end


-- // =============================[ getPositionAboveElement ] ============================================//
function getPositionAboveElement(rx, ry, rz, x, y, z)

	-- rx, ry, rz, x, y, z are all element data
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)

	-- apply transformation on a unit vector + xyz offset 
	local offX = (math.cos(rz)*math.sin(ry) + math.cos(ry)*math.sin(rz)*math.sin(rx)) + x
	local offY = (math.sin(rz)*math.sin(ry) - math.cos(rz)*math.cos(ry)*math.sin(rx)) + y
	local offZ = (math.cos(rx)*math.cos(ry)) + z
	
	-- DEBUG
	-- dxDrawLine3D(x, y, z, offX, offY, offZ, tocolor(255, 0, 0), 10)

	return offX, offY, offZ	
end
-- read more:
-- https://wiki.multitheftauto.com/wiki/GetElementMatrix


-- // =============================[ updateRacingLine, runs in assistTimer ] ============================================//
function updateRacingLine()
-- took me 0.05 ms to run
-- -- start time measurement -------------------------------------//
-- local eleje = getTickCount() local m = 1 for m=1, 20 do -------//
-- ---------------------------------------------------------------//	

	-- outputDebug("@updateRacingLine")

	-- // ====================[ loop stuff ] =======================//
	nextNode = nil
	prev_dst = math.huge
	dst = 0


-- TODO: DONT CALL THIS ON EVERY RUN
	-- no need lines for air vehicles
	if assistEnabled and vehicle then
		vType = getVehicleType(vehicle)
		if (vType == "Plane" or vType == "Helicopter" or vType == "Boat") then
			hide()
		else
			show()
		end
	end

	
	-- max time: 0,022 ms
	-- // ====================[ Find the next valid ghostpoint ] ==========================//
	-- look for nearby nodes, one with the smallest ID difference, so that the line will grip nicely to the car
	nextNode = nil	
	-- save the last, before looking for a new one
	-- !!!
	lastNodeID = nextNodeID -- remove this, if you wanna see lines on visited routes
	-- !!!
	-- search starts from the last visited node!! only looking forward
	id = lastNodeID
	while(recording[id]) do
		if recording[id].ty == "po" then	
		
			x, y, z = recording[id].x, recording[id].y, recording[id].z
			dst = getDistanceBetweenPoints3D(x, y, z, getElementPosition(getLocalPlayer()))	
			-- get nearby unvisited points
			if (dst < 50 and id >= lastNodeID) then -- ugly constant here
				nextNode = id
				break
			end	
			
		end -- type
		id = id + 1			
	end -- while

	-- // ====================[ Find the nearest valid ghostpoint ] ==========================//
	-- if a valid next node was found, scroll trough a few nodes and find one near the player
	if (nextNode ~= nil) then
		prev_dst = math.huge
		dst = 0
	
		if (vehicle) then
			-- looking for a node pair, where "next" is further than "prev", that will be close to player
			-- NOTE: this isnt supposed to work
			for id = 1,6 do
				x, y, z = getElementPosition(vehicle)
				prev = recording[nextNode]	
				
				idx = nextNode + 1			
				curr = recording[idx]
				if (curr and prev) then
					prev_dst = getDistanceBetweenPoints3D(prev.x, prev.y, prev.z, x, y, z) or 0
					dst = getDistanceBetweenPoints3D(curr.x, curr.y, curr.z, x, y, z) or 0
					
					if (prev_dst > dst) then
						-- !!!
						-- this will be the nearest valid node to player
						nextNodeID = idx
						-- !!!
						-- outputChatBox("break at: "..id) -- DEBUG
						break
					end
					-- DEBUG
					-- outputChatBox("i: "..id) -- DEBUG
					-- dxDrawText( inspect(prev), 200, 440, 250)	
					-- dxDrawText( inspect("prev id: "..nextNode .." ".. prev_dst), 200, 420, 250)
					-- dxDrawText( inspect(curr), 400, 440, 250)	
					-- dxDrawText( inspect("next id: "..idx .." ".. dst), 400, 420, 250)		
				end -- if
			end -- for
		end -- vehicle
	
		-- old solution: not the nearest node, but grips nicely to the car
		-- nextNodeID = nextNode
			
	end -- nil

	
	-- // =====================[ Calculate arrow size] ============================//
	-- resize arrow based on vehicle size
	my_weight = 1500
	arrowSize = 2
	if (vehicle) then
		my_weight = (getVehicleHandling(vehicle).mass)
		-- outputChatBox(my_weight)
	end		
	arrowSize = math.clamp(1, (0.04*my_weight+180)/200, 3) -- dirt 3 style arrow size
	-- arrowSize = math.clamp(1.5, (0.04*my_weight+180)/150, 5) -- forza style arrow size
	
-- -- stop time measurement -------------------------------------------------------------------------------//
-- end local vege = getTickCount()	outputDebug( "ms time spent: " .. vege-eleje) --//	
-- --------------------------------------------------------------------------------------------------------//	
end -- updateRacingLine


-- // =============================[ drawRacingLine onClientPreRender ] ============================================//
function drawRacingLine()
	-- took me 1-2 ms to run
	-- -- start time measurement -------------------------------------//
	-- local eleje = getTickCount() local m = 1 for m=1,20 do --------//
	-- ---------------------------------------------------------------//	

	
	-- // ====================[ DEBUG: Show the full racing line, highlight nearby and next nodes ] =======================//
	-- local nearbyNodes = {}
	-- local i = 1
	-- node1 = recording[i]
	-- node2 = recording[i+1]
	-- while(node1 and node2) do
		-- -- one piece of race line
		-- dxDrawLine3D (node1.x, node1.y, node1.z-0.4, node2.x, node2.y, node2.z-0.4, tocolor(255,255,255, 128), 8)	

		-- dst = getDistanceBetweenPoints3D(node1.x, node1.y, node1.z, getElementPosition(getLocalPlayer()))
		-- if (dst < 50) then
			-- -- one nearby node
			-- dxDrawLine3D (node1.x, node1.y, node1.z-0.6, node1.x, node1.y, node1.z-0.4, tocolor (255,0,0, 255), 25)
			-- -- store nearby points
			-- table.insert(nearbyNodes, i, dst) 				
		-- end		
		-- i = i + 1	
		-- node1 = recording[i]
		-- node2 = recording[i+1]	
	-- end
	-- -- show the table of nearby nodes
	-- if (nearbyNodes) then
		-- dxDrawText(inspect(nearbyNodes), 200, 500, 250)
	-- end	
	-- -- draw the next node
	-- node1 = recording[nextNodeID] 
	-- if (node1) then
		-- dxDrawLine3D (node1.x, node1.y, node1.z-0.6, node1.x, node1.y, node1.z-0.4, tocolor(0,255,0, 255), 40)
	-- end		
	
	
	-- DEBUG
	-- dxDrawText( getVehicleType(vehicle), 800, 440, 1920, 1080, tocolor(255, 128, 0, 255), 1, "pricedown")
	
	-- // =================================[ Draw racing line section near player ] =====================================//	
	vehicle = getPedOccupiedVehicle(getLocalPlayer()) -- keep this
	local start = nextNodeID
	
	-- draw the next few nodes
	for i = start, start+15, 1 do -- ugly constant here
		node1 = recording[i]
		node2 = recording[i+1]
		-- need 2 valid nodes to make a line AND being in a vehicle to continue
		if (node1 and node2 and vehicle) then

			-- looks better
			rx, ry, rz = node1.rX, node1.rY, node1.rZ
			if (rx > 180) then rx = rx - 360 end
			if (ry > 180) then ry = ry - 360 end	
		
			-- // =================[ get ghost and player speed at EVERY PIECE OF RACE LINE ] =======================//
			vx, vy, vz = node1.vX, node1.vY, node1.vZ
			ghost_speed = getDistanceBetweenPoints3D(0, 0, 0, vx, vy, vz)
			my_speed = getDistanceBetweenPoints3D(0, 0, 0, getElementVelocity(vehicle))
			my_dst = getDistanceBetweenPoints3D(node1.x, node1.y, node1.z, getElementPosition(vehicle))
			-- speed_err = (ghost_speed - my_speed) * 160 -- old: speed difference roughly in kmh
			-- !!!
-- TODO: need a sensitivity setting here, somewhere. careful with saturation
			speed_err = 1*((my_speed - ghost_speed)/ghost_speed)  -- relative speed error
			-- !!!
			
			-- DEBUG
			-- if i == start then dxDrawText ("speed error: "..math.floor(speed_err*100).. " %", 800, 440, 1920, 1080, tocolor(255, 128, 0, 255), 1, "pricedown") end 
			-- if i == start then dxDrawText ("my speed: ".. math.floor(my_speed*160), 800, 480, 1920, 1080, tocolor(255, 128, 0, 255), 1, "pricedown") end 
			-- if i == start then dxDrawText ("ghost speed: ".. math.floor(ghost_speed*160), 800, 520, 1920, 1080, tocolor(255, 128, 0, 255), 1, "pricedown") end 						

			-- // =========================[ Speed color coding ] ==============================//
			-- speed color coding FOR RELATIVE SPEED ERROR, red=too fast, green=okay, white=too slow
			-- scaled to [-50%, 50%] relative speed error interval
			-- speed_err = 0.5 means u go 50% faster than the ghost
			color_r = math.clamp(0, 510*math.abs(speed_err), 255)
			color_g = math.clamp(0, -510*speed_err + 255, 255)
			color_b = math.clamp(0, -510*speed_err, 255)
			color_a = math.clamp(0, 0.5*my_dst^2, 175) -- sharp fade				
			
			-- -- different color for every line piece based on speed difference, simple linear funcs
			-- -- speed color coding, red=too fast, white=normal, green=too slow
			-- color_r = math.clamp(0, -10*speed_err + 255, 255)
			-- color_g = math.clamp(0, 10*speed_err + 255, 255)
			-- color_b = math.clamp(0, -0.8*speed_err^2 + 255, 255)
			-- color_a = math.clamp(0, -5*speed_err, 255) -- shows only brake lines
			
			-- -- -- speed color coding, red=too fast, green=normal, white=too slow
			-- -- scaled to [-25, 25] kmh speed diff interval
			-- color_r = math.clamp(0, math.abs(-10*speed_err), 255)
			-- color_g = math.clamp(0, 10*speed_err + 255, 255)
			-- color_b = math.clamp(0, 10*speed_err, 255)
			-- -- color_a = math.clamp(0, 40*my_dst, 175) -- fades near player	
			-- color_a = math.clamp(0, 0.5*my_dst^2, 175) -- sharper fade
			
			-- -- speed color coding, red=too fast, green=normal or slow
			-- -- scaled to [-25, 25] kmh speed diff interval
			-- color_r = math.clamp(0, -10*speed_err, 255)
			-- color_g = math.clamp(0, 10*speed_err + 255, 255)
			-- color_b = 0
			-- color_a = math.clamp(0, 0.5*my_dst^2, 175)		

			
			-- // =======================================[ Draw one line piece ]===========================================//
			-- RGBcolored forza arrows, faced straight up
			-- dxDrawMaterialLine3D (x, y, z-0.5, node2.x, node2.y, node2.z-0.5, img, 2, tocolor(color_r, color_g, color_b, 100), x, y, z)
			
			-- forza arrows, dynamic RGBA, facing original ghost orientation
			-- getGroundPosition sucks for sideways coaster maps
			-- fx, fy, fz = getPositionAboveElement(rx, ry, rz, x, y, z)
			-- dxDrawMaterialLine3D(x, y, z-0.5,node2.x, node2.y, node2.z-0.5, img, arrowSize, tocolor(color_r, color_g, color_b, color_a), fx, fy, fz)		
			
			-- forza arrows, dynamic RGBA, facing original ghost orientation, snapped to ground
			-- dxDrawMaterialLine3D(x, y, getGroundPosition(x,y,z)+0.15, node2.x, node2.y, getGroundPosition(node2.x,node2.y,node2.z)+0.15, img, arrowSize, tocolor(color_r, color_g, color_b, color_a), fx, fy, fz)
			
			-- simple  colored line
			-- dxDrawLine3D (node1.x, node1.y, node1.z, node2.x, node2.y, node2.z, tocolor(color_r, color_g, color_b, color_a), 20)	
			
			-- !!!
			-- place them near ground
			gz = getGroundPosition(node1.x, node1.y, node1.z)
			-- rotate the arrows correctly
			fx, fy, fz = getPositionAboveElement(rx, ry, rz, node1.x, node1.y, gz)
			-- rx > 80: going straight up or upside down
			-- ry > 70 going sideways on a wall
			if (math.abs(rx) < 80 and math.abs(ry) < 70 and math.abs(gz - node1.z) < 10) then
				dxDrawMaterialLine3D(
					node1.x, node1.y, gz + 0.15, 
					node2.x, node2.y, getGroundPosition(node2.x, node2.y, node2.z) + 0.15, 
					img, arrowSize, tocolor(color_r, color_g, color_b, color_a), 
					fx, fy, fz
				)
			end	

			-- DEBUG
			-- outputChatBox(rx ..", ".. ry ..", ".. rz)
			-- outputChatBox(speed_err) -- DEBUG
			-- outputChatBox(color_a) -- DEBUG
			-- outputChatBox(getGroundPosition(x,y,z)-z)
					
		end	-- node check
	end	-- for

	-- -- stop time measurement -------------------------------------------------------------------------------//
	-- end local vege = getTickCount()	dxDrawText( inspect("ms time spent: " .. vege-eleje), 400, 420, 250) --//	
	-- --------------------------------------------------------------------------------------------------------//

end -- drawRacingLine
-- read more:
-- http://mathworld.wolfram.com/RelativeError.html