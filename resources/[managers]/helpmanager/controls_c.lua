---------------
-- Detecting --
---------------

function detectFalling()
	local veh = getPedOccupiedVehicle(localPlayer)
	local vel = isElement(veh) and {getElementVelocity(veh)}
	if isElement(veh) and getVehicleType(veh) ~= "Plane"
		and math.abs(vel[1]) < 0.1 and math.abs(vel[2]) < 0.1 and vel[3] < -1.8 
	then
		checkEvent ( "respawn" )
	end
end
setTimer(detectFalling, 1000, 0)

function vehicleDetect ( oldid, newid )
	local vehicle = source
	local model = newid
	local type = getVehicleType(model)
	if model == 520 then 		-- hydra
		checkEvent ( "hydra" )
	elseif model == 513 then		-- stuntplane
		checkEvent ( "stuntplane" )
	elseif type == "Plane" then	-- plane
		checkEvent ( "plane" )
	elseif type == "Bike" or type == "Quad" then
		checkEvent ( "bikes" )
	elseif type == "BMX" then
		checkEvent ( "bicycle" )
	end
end
addEvent("onClientVehicleChange", true)
addEventHandler("onClientVehicleChange", root, vehicleDetect)

function vehicleEnter ( vehicle, _seat )
	local model = getElementModel(vehicle)
	local type = getVehicleType(vehicle)
	if model == 520 then 		-- hydra
		checkEvent ( "hydra" )
	elseif model == 513 then		-- stuntplane
		checkEvent ( "stuntplane" )
	elseif type == "Plane" then	-- plane
		checkEvent ( "plane" )
	elseif type == "Bike" or type == "Quad" then
		checkEvent ( "bikes" )
	elseif type == "BMX" then
		checkEvent ( "bicycle" )
	end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, vehicleEnter)

function nitroEvent()
	checkEvent ( "nitro" )
end
addEvent("onClientPickUpNitro", true)
addEventHandler("onClientPickUpNitro", root, nitroEvent)


------------
-- Saving --
------------

local filepath = '@controls.xml'
local events_thismap = {}

function checkEvent ( event )
	--outputChatBox("going for " .. event)
	if busy or events_thismap [ event ] then return end
	local node = xmlLoadFile(filepath)
	if not node then return end
	--outputChatBox(event .. " is ON")
	local node_event = xmlFindChild ( node, event, 0 )
	if not node_event then
		node_event = xmlCreateChild ( node, event )
		xmlNodeSetValue ( node_event, "1" )
	else
		local amount = tonumber ( xmlNodeGetValue ( node_event ) ) or 1
		if amount >= 1 then
			return	-- nothing to see here
		else
			xmlNodeSetValue ( node_event, tostring ( amount + 1 ) )
		end
	end
	xmlSaveFile(node)
	xmlUnloadFile(node)
	events_thismap [ event ] = true
	importText ( event )
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	local node = xmlLoadFile(filepath)
	if not node then
		node = xmlCreateFile(filepath,'root')
		--outputChatBox("created")
		xmlSaveFile(node)
	end
	xmlUnloadFile(node)
end
)

addEvent("onGamemodeMapStart", true)
addEventHandler("onGamemodeMapStart", root, function()
	--outputChatBox("reset")
	events_thismap = {}
end)

----------
-- Text --
----------

local texts = {
-- event = { {control_name1, control_name2, ..}, "[<Key1>] blabla1\n[<Key2>] blabla2,..}
hydra = { {"special_control_down", "special_control_up", "sub_mission"}, "[<Key1>]  Hover\n[<Key2>]  Fly forward\n[<Key3>]  Landing gear"},
stuntplane = { {"special_control_down", "special_control_up", "sub_mission"}, "[<Key1>]  Hover\n[<Key2>]  Fly forward\n[<Key3>]  Smoke"},
plane = { {"steer_back", "steer_forward", "sub_mission"}, "[<Key1>]  Steer up\n[<Key2>]  Steer down\n[<Key3>]  Landing gear"},
bikes = { {"steer_back", "steer_forward"}, "[<Key1>]  Lean backward\n[<Key2>]  Lean forward"},
bicycle = { {"accelerate","vehicle_fire"}, "[<Key1>]  Tapping=faster\n[<Key2>]  Jump"},
respawn = { {"Commit suicide"}, "[<Key1>]  Respawn"},
nitro = { {"vehicle_fire"}, "[<Key1>]  Nitro boost"},
}

function clearKeyName(s)
	-- possibility to rename the key to a more readable name here
	return tostring(s)
end

function importText(event)
	if not texts[event] then return outputDebugString("Error: no such event to show controls", 3) end
	-- local text = "[ENTER] Respawn\n[LMB] Nitro\n baaaaaaaaap\n ba\neeee"
	local text = texts[event][2]
	local controls = texts[event][1]
	for i, control_name in ipairs(controls) do
		local control_key = getKeyBoundToCommand(control_name)
		-- outputChatBox(tostring(control_name) .. " " .. tostring(keys[1]))
		if not control_key then
			local keys = {}
			for _key, state in pairs(getBoundKeys(control_name)) do
				table.insert(keys, _key)
			end
			control_key = clearKeyName(keys[1])
		end
		-- outputChatBox(tostring(control_name) .. " " .. tostring(keys[1]))
		text = string.gsub(text, "<Key" .. i .. ">", control_key, 1)
	end
	local delay = 250
	local fade = 1000
	local length = 10000
	showcontrols ( text, delay, fade, length )
end


-----------
--Drawing--
-----------

local sX, sY = guiGetScreenSize()
local scale = 1.75
local font = "arial"
local margeH = 15
local width, newlines, heigth, left, right, top, bottom, _
local color = {255,185,15}
local backAlpha = 155

local fadeIn, showText, fadeOut, stopText
local sText, showing, busy

function showcontrols ( text, delay, fade, length )
	if busy then return else busy = true end
		-- outputChatBox("burp " .. getTickCount())

	width = dxGetTextWidth ( text, scale, font )
	_, newlines = string.gsub(text,"\n", "\n")
	heigth = dxGetFontHeight(scale, font) * ((newlines or -1) +1)
	left = sX - width - margeH
	right = sX - margeH + 1
	top = (sY-heigth)/2
	bottom = (sY+heigth)/2
	
	sText = text
	fadeIn = getTickCount() + delay
	showText = fadeIn + fade
	fadeOut = showText + length
	stopText = fadeOut + fade
end

addEventHandler ( "onClientRender", root, function()
	if not busy then return end
	local tick = getTickCount()
	if fadeIn <= tick and tick <= stopText then
		local alpha = 0
		if tick < showText then
			alpha = backAlpha * (tick - fadeIn)/(showText - fadeIn)
		elseif showText < tick  and tick < fadeOut then
			alpha = backAlpha
		elseif fadeOut < tick and tick < stopText then
			alpha = backAlpha * (stopText - tick)/(stopText - fadeOut)
		end
		rectAlpha = math.floor ( math.abs ( alpha ) )
		textAlpha = math.floor ( alpha * 255 / backAlpha )
		dxDrawRectangle(left - margeH/2, top - margeH/2, width + margeH, heigth + margeH, tocolor(0,0,0,rectAlpha))
		dxDrawText ( sText, left, top, right, bottom, tocolor(color[1], color[2], color[3], textAlpha), scale, font )
	elseif tick > stopText then
		busy = nil
	end
end )