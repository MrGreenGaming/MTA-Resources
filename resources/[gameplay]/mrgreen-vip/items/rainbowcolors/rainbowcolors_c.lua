local rainbowPlayers = {}
local rainbowSteps = {
	{255,	0,		0},
	{255,	255,	0},
	{0,		255,	0},
	{0,		255,	255},
	{0,		0,		255},
	{255,	0,		255},
	{255,	255,	255},
	{0,		0,		0},
}
local currentStep = 1
local start, tick = false, false
local timeStep = 1000
local lastDifference = false


function makeColorChange ()

	tick = getTickCount()
	if tablelength(rainbowPlayers) > 0 then
		if not start then 
			start = tick
			if lastDifference then
				start = start + lastDifference
				lastDifference = false
			end
		end
		local r, g, b = calculateRainbowRGB()

		for player, v in pairs(rainbowPlayers) do
			if not isElement(player) then return end

			local veh = getPedOccupiedVehicle( player )
			if isElement(player) and isElement(veh) and getElementType(veh) == 'vehicle' and isElementStreamedIn(veh) then
				setVehicleColor(veh, r, g, b, r, g, b, r, g, b, r, g, b)
				setVehicleHeadLightColor( veh, r, g, b )
			end
		end
	end
end
addEventHandler( 'onClientRender', root, makeColorChange )



addEventHandler( 'onClientResourceStart', resourceRoot, function () 
	for i,v in ipairs( getElementsByType( 'player' ) ) do
		if getElementData( v, 'vip.rainbow' ) then
			rainbowPlayers[v] = true
		end
	end


end)

addEventHandler( 'onClientElementDataChange', root, function (key,old,new) 
	if key == 'vip.rainbow' then
		if getElementData( source, 'vip.rainbow' ) then
			rainbowPlayers[source] = true
		else
			rainbowPlayers[source] = nil
			local veh = getPedOccupiedVehicle( source )
			if veh then
				setVehicleColor( veh, 255, 255, 255,255, 255, 255,255, 255, 255,255, 255, 255 )
			end
		end
	end
end)

addEventHandler( 'onClientPlayerQuit', root, function()  
	if rainbowPlayers[source] then
		rainbowPlayers[source] = nil
	end
end)


--utils
function calculateRainbowRGB()
	if (tick - start) >= timeStep then
		currentStep = currentStep + 1
		if currentStep > #rainbowSteps then
			currentStep = 1
		end
		start = tick
		return calculateRainbowRGB()
	else
		local lastStep = currentStep - 1
		if currentStep == 1 then
			lastStep = #rainbowSteps
		end
		local progress = (tick - start) / timeStep
		progress = clamp(0, progress, 1)
		return interpolateBetween(rainbowSteps[lastStep][1], rainbowSteps[lastStep][2], rainbowSteps[lastStep][3], rainbowSteps[currentStep][1], rainbowSteps[currentStep][2], rainbowSteps[currentStep][3], progress, 'Linear')
	end
end

function clamp(mi, value, ma)
	return math.max(mi, math.min(ma, value))
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end