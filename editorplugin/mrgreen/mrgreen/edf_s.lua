local elements = {}
local mode

addEventHandler( "onResourceStart", root, function ( res )
	if getResourceName(res) ~= "editor_test" then return end
	outputDebugString('editor_test start mrgreen')
	
	local getmode = get('editor_test.racemode')
	local racemode = ({		--having fun
		rtf = startRTF,
		shooter = startSH,
		nts = startNTS,
		ctf = startCTF,
	})[getmode and string.lower(getmode)]
	
	if ( racemode ) then
		mode = string.lower(getmode)
		outputChatBox ( "mrgreen loading mode " .. getmode )
		if (#getElementsByType('spawnpoint', (source) ) < 50) then
			outputChatBox('WARNING: Maps should have atleast 50 spawnpoints', root, 255, 0, 0)
		end
		racemode(source)
	end

	-- while testing in map editor this triggers twice for each randommarker, fuck it i dont know why
	for _, mrkr in ipairs( getElementsByType'randommarker', getResourceRootElement(res) ) do
		local x, y, z = getElementPosition(mrkr)
		elements[#elements+1] = createMarker (x, y, z, "cylinder", markersize, 0, 255, 0, 150) -- Creates the markers
		setElementParent(elements[#elements], mrkr)
		addEventHandler('onMarkerHit', elements[#elements], function(hitElement, dim)
			if not (dim and getElementType(hitElement) == 'vehicle' and not isVehicleBlown(hitElement) and getVehicleController(hitElement) and getElementHealth(getVehicleController(hitElement)) ~= 0) then return end
			outputChatBox('Markers: You picked up a RandomMarkers pickup', getVehicleController(hitElement), 0, 255, 0)
		end)
	end
	
	for _, mrkr in ipairs( getElementsByType'coremarker', getResourceRootElement(res) ) do
		local x, y, z = getElementPosition(mrkr)
		local col = createColSphere(x, y, z, 3.7)
		elements[#elements+1] = col
		local object = createObject(3798, x, y, z+0.3)
		local marker = createMarker (x, y, z-2.75, "cylinder", 3.3, 0, 255, 0, 150)
		setElementParent(object, col)
		setElementParent(marker, col)
		setObjectScale(object, 0.6)
		setElementCollisionsEnabled(object, false)
		addEventHandler("onColShapeHit", col, function(thePlayer)
			if getElementType(thePlayer) == "player" then
				outputChatBox('Markers: You picked up a CoreMarkers pickup', thePlayer, 0, 255, 0)
			end
		end)
	end
end)

addEventHandler( "onResourceStop", root, function ( res )
	if getResourceName(res) ~= "editor_test" then return end
	outputDebugString('editor_test stop mrgreen')
	for i=1,#elements do
		destroyElement(elements[i])
		elements[i] = nil
	end
	triggerClientEvent('shooter', root, false)
	removeEventHandler('onPlayerReachCheckpoint', root, ntsCheckpoint)
	removeEventHandler('checkpoints', resourceRoot, ntscheckpoints)
	mode = nil
end )

function startRTF(res)
	local rtfflags = getElementsByType('rtf', res)
	if (#rtfflags ~= 1) then
		outputChatBox('WARNING: RTF map should have 1 flag, this map has ' ..  tostring(#rtfflags), root, 255, 0, 0)
	end
	if (#getElementsByType('checkpoint', (res) ) > 0) then
		outputChatBox('WARNING: RTF map should not have checkpoints', root, 255, 0, 0)
	end
	
	outputDebugString("RTF: " .. #rtfflags)
	for i=1,#rtfflags do
		local x, y, z = getElementPosition(rtfflags[i])
		elements[#elements+1] = createObject(2993, x, y, z)
		elements[#elements+1] = createMarker ( x, y, z-0.5, 'corona', 1.5, 0, 255, 0 )
		elements[#elements+1] = createColSphere ( x, y, z, 2 )
		addEventHandler('onColShapeHit', elements[#elements], function(hitElement, dim)
			if not (dim and getElementType(hitElement) == 'vehicle' and not isVehicleBlown(hitElement) and getVehicleController(hitElement) and getElementHealth(getVehicleController(hitElement)) ~= 0) then return end
			outputChatBox('RTF: You finished', getVehicleController(hitElement), 0, 255, 0)
		end)
		elements[#elements+1] = createBlipAttachedTo(elements[#elements], 19, 5, 255, 255, 255, 255, 500)
	end
end

function startSH(res)
	if (#getElementsByType('checkpoint', (res) ) > 0) then
		outputChatBox('WARNING: Shooter map should not have checkpoints', root, 255, 0, 0)
	end
	triggerClientEvent('shooter', root, true)
end
function startNTS(res)
	checkpoints = {}
	addEventHandler('onPlayerReachCheckpoint', root, ntsCheckpoint)
	addEventHandler('checkpoints', resourceRoot, ntscheckpoints)
end
addEvent'onPlayerReachCheckpoint'

-- fun below
local vehs = {
vehicle = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585, 405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 485, 552, 431, 438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524, 423, 532, 414, 578, 443, 486, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534, 567, 535, 576, 412, 402, 542, 603, 475, 568, 557, 424, 471, 504, 495, 457, 539, 483, 508, 571, 500, 411, 515, 444, 556, 429, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458}, 
boat = {472,473,493,595,484,430,453,452,446,454,}, 
air = {592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513,}
}
local col={vehicle={0,0,255}, boat={0,255,0}, air={255,0,0}, custom={0,0,0}}
local g_Checkpoints
function ntscheckpoints(checkpoints)
	for k,c in ipairs(checkpoints) do
		local ch = getElementByID(c.id)
		local cpName = tostring(getElementData(ch, 'id'))
		local nts = tostring(getElementData(ch, 'nts') )
		if not(col[nts]) then
			outputChatBox("WARNING: Checkpoint \"" .. c.id .. '" doesn\'t have a valid NTS type {' .. nts .. '}', root, 255,0,0)
		end
		if nts == "custom" then
			local modelNr = 1
			vehs[cpName] = {}
			local models = tostring(getElementData(ch, "models"))
			for model in string.gmatch(models, "([^;]+)") do
				if getVehicleNameFromModel(model) == "" then
					outputChatBox("WARNING: Model " .. model .. " is not a valid model for checkpoint " .. c.id .. "!", root, 255,0,0)
					outputChatBox("WARNING: Make sure to separate all models with the ; character!", root, 255,0,0)
				else
					vehs[cpName][modelNr] = model
					modelNr = modelNr + 1
				end
			end
		end
	end
	g_Checkpoints = checkpoints
end
addEvent('checkpoints', true)
function ntsCheckpoint(i)
	outputDebugString('ntsCheckpoint ' .. i )
	local ch = getElementByID(g_Checkpoints[i].id)
	local cpName = tostring(getElementData(ch, 'id'))
	local nts = tostring(getElementData(ch, 'nts')) or ""
	if nts == "vehicle" then
		setElementModel(getPedOccupiedVehicle(source), vehs["vehicle"][math.random(1, table.getn(vehs["vehicle"]))])
	elseif nts == "boat" then
		setElementModel(getPedOccupiedVehicle(source), vehs["boat"][math.random(1, table.getn(vehs["boat"]))])
	elseif nts == "air" then
		setElementModel(getPedOccupiedVehicle(source), vehs["air"][math.random(1, table.getn(vehs["air"]))])
	elseif nts == "custom" then
		if table.getn(vehs[cpName]) > 0 then
			setElementModel(getPedOccupiedVehicle(source), vehs[cpName][math.random(1, table.getn(vehs[cpName]))])
		else
			outputChatBox("No valid NTS model(s) specified for checkpoint " .. cpName .. ".")
		end
	else
		outputChatBox("No valid NTS type specified for checkpoint " .. cpName .. ".")
	end
	local vehicle = getPedOccupiedVehicle(source)
	local x, y, z = getElementPosition(vehicle)
	setElementPosition(vehicle, x, y, z+1)
end
-- fun has been terminated

function startCTF(res)
	for i,spawnpoint in ipairs(getElementsByType"spawnpoint", res) do
		if not exports.edf:edfGetElementProperty ( spawnpoint, "team" ) then
			outputChatBox("CTF WARNING: Spawnpoint \"" .. getElementID(spawnpoint) .. '" doesn\'t have a team assigned', root, 255,0,0)
		end
	end
	if (#getElementsByType('checkpoint', (res) ) > 0) then
		outputChatBox('WARNING: CTF map should not have checkpoints', root, 255, 0, 0)
	end
	local ctfblue = getElementsByType('ctfblue', res )
	if (#ctfblue ~= 1) then
		outputChatBox('WARNING: CTF map should have 1 blue flag, this map has ' ..  tostring(#ctfblue), root, 255, 0, 0)
	end
	local ctfred = getElementsByType('ctfred', res )
	if (#ctfred ~= 1) then
		outputChatBox('WARNING: CTF map should have 1 red flag, this map has ' ..  tostring(#ctfred), root, 255, 0, 0)
	end
	for i=1,#ctfblue do
		local x, y, z = getElementPosition(ctfblue[i])
		elements[#elements+1] = createObject(2048, x, y, z)
		elements[#elements+1] = createMarker ( x, y, z-0.5, 'cylinder', 1.5, 0,0,255 )
		elements[#elements+1] = createColSphere ( x, y, z, 2 )
		addEventHandler('onColShapeHit', elements[#elements], function(hitElement, dim)
			if not (dim and getElementType(hitElement) == 'vehicle' and not isVehicleBlown(hitElement) and getVehicleController(hitElement) and getElementHealth(getVehicleController(hitElement)) ~= 0) then return end
			outputChatBox('CTF: You hit the blue base flag', getVehicleController(hitElement), 0, 0, 255)
		end)
		elements[#elements+1] = createBlipAttachedTo(elements[#elements], 0, 4, 0, 0, 255)
	end
	for i=1,#ctfred do
		local x, y, z = getElementPosition(ctfred[i])
		elements[#elements+1] = createObject(2914, x, y, z)
		elements[#elements+1] = createMarker ( x, y, z-0.5, 'cylinder', 1.5, 255,0,0 )
		elements[#elements+1] = createColSphere ( x, y, z, 2 )
		addEventHandler('onColShapeHit', elements[#elements], function(hitElement, dim)
			if not (dim and getElementType(hitElement) == 'vehicle' and not isVehicleBlown(hitElement) and getVehicleController(hitElement) and getElementHealth(getVehicleController(hitElement)) ~= 0) then return end
			outputChatBox('CTF: You hit the red base flag', getVehicleController(hitElement), 255, 0, 0)
		end)
		elements[#elements+1] = createBlipAttachedTo(elements[#elements], 0, 4, 255, 0, 0)
	end
end

function onMapOpened()
	for i,spawnpoint in ipairs(getElementsByType"spawnpoint") do
		local team = exports.edf:edfGetElementProperty ( spawnpoint, "team" )
		local vehicle = getRepresentation(spawnpoint, "vehicle")
		if team == "blue" then
			setVehicleColor ( vehicle, 0,0,255, 0,0,255, 0,0,255, 0,0,255 )
		elseif team == "red" then
			setVehicleColor ( vehicle, 255,0,0, 255,0,0, 255,0,0, 255,0,0 )
		end		
	end
	for i,checkpoint in ipairs(getElementsByType"checkpoint") do
		local nts = exports.edf:edfGetElementProperty ( checkpoint, "nts" )
		if col[nts] then
			exports.edf:edfSetElementProperty ( checkpoint, "color",  string.format("#%.2X%.2X%.2X", col[nts][1],col[nts][2],col[nts][3]) )
		end
	end
end
addEventHandler ( "onMapOpened", root, onMapOpened)

function onElementPropertyChanged(propertyName)
	if propertyName == "team" then
		for i,spawnpoint in ipairs(getElementsByType"spawnpoint") do
			local team = exports.edf:edfGetElementProperty ( spawnpoint, "team" )
			local vehicle = getRepresentation(spawnpoint, "vehicle")
			if team == "blue" then
				setVehicleColor ( vehicle, 0,0,255, 0,0,255, 0,0,255, 0,0,255 )
			elseif team == "red" then
				setVehicleColor ( vehicle, 255,0,0, 255,0,0, 255,0,0, 255,0,0 )
			end		
		end
	elseif propertyName == "nts" then
		for i,checkpoint in ipairs(getElementsByType"checkpoint") do
			local nts = exports.edf:edfGetElementProperty ( checkpoint, "nts" )
			if col[nts] then
				exports.edf:edfSetElementProperty ( checkpoint, "color",  string.format("#%.2X%.2X%.2X", col[nts][1],col[nts][2],col[nts][3]) )
			end
		end
	end
end
addEventHandler ( "onElementPropertyChanged", root, onElementPropertyChanged)

function MarkerColorChange () -- Random Colors for the markers
	for _, mrkr in pairs( getElementsByType'marker' ) do
		if getElementType(getElementParent(mrkr)) == 'randommarker' then
			setMarkerColor ( mrkr, math.random (0,255), math.random (0,255), math.random (0,255), 50 )
		end
	end
	if not (getResourceFromName'edf' and getResourceState(getResourceFromName'edf') == 'running') then return end
	for _, mrkr in pairs( getElementsByType'randommarker' ) do
		if getRepresentation(mrkr, 'marker') then
			setMarkerColor ( getRepresentation(mrkr, 'marker'), math.random (0,255), math.random (0,255), math.random (0,255), 50 )
		end
	end
end
markertimer = setTimer ( MarkerColorChange, 120, 0 )

function getRepresentation(element,type)
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle ( elem ) then
			return elem
		end
	end
	return false
end
