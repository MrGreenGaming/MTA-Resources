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
local rainbowAllowedPaintjob = false

function makeColorChange ()
	if not rainbowAllowedPaintjob then return end

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
				-- outputDebugString( "paintjob: "..tostring(v.paintjob).." - wheels: "..tostring(v.wheels).." - lights: "..tostring(v.lights) )
				if rainbowAllowedPaintjob then
					if v.paintjob and v.wheels then
						-- set full color
						setVehicleColor(veh, r, g, b, r, g, b, r, g, b, r, g, b)
					elseif v.paintjob and not v.wheels then
						-- Set paintjob only
						local _,_,_,_,_,_,r1,g1,b1,r2,g2,b2 = getVehicleColor( veh, true )
						setVehicleColor(veh, r, g, b, r, g, b, r1, g1, b1, r2, g2, b2)
					elseif not v.paintjob and v.wheels then
						-- Wheels only
						local r1,g1,b1,r2,g2,b2 = getVehicleColor( veh, true )
						setVehicleColor(veh, r1,g1,b1,r2,g2,b2, r, g, b, r2, g2, b2)
					end

					if v.lights then
						-- Set headlight colors
						setVehicleHeadLightColor( veh, r, g, b )
					end
				else
					-- Only handle wheels and lights
					if v.wheels then
						local r1,g1,b1,r2,g2,b2 = getVehicleColor( veh, true )
						setVehicleColor(veh, r1,g1,b1,r2,g2,b2, r, g, b, r2, g2, b2)
					end

					if v.lights then
						setVehicleHeadLightColor( veh, r, g, b )
					end
				end
			end
		end
	end
end
addEventHandler( 'onClientRender', root, makeColorChange )



addEventHandler( 'onClientResourceStart', resourceRoot, function () 
	for i,v in ipairs( getElementsByType( 'player' ) ) do
		if getElementData( v, 'vip.rainbow' ) and checkRainbowValidData(getElementData( v, 'vip.rainbow' ))  then
			rainbowPlayers[v] = getElementData( v, 'vip.rainbow' )
		end
	end


end)

addEventHandler( 'onClientElementDataChange', root, function (key,old,new) 
	if key == 'vip.rainbow' then
		if getElementData( source, 'vip.rainbow' ) and checkRainbowValidData(getElementData( source, 'vip.rainbow' )) then
			rainbowPlayers[source] = getElementData( source, 'vip.rainbow' )
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

function checkRainbowValidData(data)
	if not data then return false end
	if data.lights == nil or data.wheels == nil or data.paintjob == nil then return false end
	return true
end

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

-- Disallowed modes
local disallowedModes = {
	['capture the flag'] = true
}
addEvent('onClientMapStarting' , true )
addEventHandler( 'onClientMapStarting', root, 
	function(mapinfo) 
		if mapinfo.modename and disallowedModes[string.lower(mapinfo.modename)] then
			rainbowAllowedPaintjob = false
		else
			rainbowAllowedPaintjob = true
		end
	end
)