local elements = {}

addEventHandler( "onResourceStart", root, function ( res )
	if getResourceName(res) ~= "editor_test" then return end
	
	local coremarkersRes = getResourceFromName("coremarkers")
	if coremarkersRes and getResourceState( coremarkersRes ) == "running" then return end
	for _, mrkr in ipairs( getElementsByType'coremarker', getResourceRootElement(res) ) do
		if getElementType(getElementParent(mrkr)) == "map" then --ignore elements with parent mapContainer (they are created by map editor), only elements from the .map will be used
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
			
			------------------------
			-- Floating Animation --
			------------------------
			local animationSpeed = 1 --the more the slower
			local box_posZ = 0.3
			local amplitude = 0.1
			local easing = "InOutQuad"
			moveObject(object, animationSpeed*1000, x, y, z+box_posZ+amplitude, 0, 0, 0, easing)
			setTimer(
				function()
					if isElement(object) then 
						moveObject(object, animationSpeed*1000, x, y, z+box_posZ-amplitude, 0, 0, 0, easing)
					end
				end
			, animationSpeed*1000, 1)
			setTimer(
				function() 
					if isElement(object) then 
						moveObject(object, animationSpeed*1000, x, y, z+box_posZ+amplitude, 0, 0, 0, easing) 
						setTimer(
							function()
								if isElement(object) then
									moveObject(object, animationSpeed*1000, x, y, z+box_posZ-amplitude, 0, 0, 0, easing)
								end
						end, animationSpeed*1000, 1)
					end 
				end
			, animationSpeed*2000, 0)
		end
	end
end)

addEventHandler( "onResourceStop", root, function ( res )
	if getResourceName(res) ~= "editor_test" then return end
	for i=1,#elements do
		destroyElement(elements[i])
		elements[i] = nil
	end
end )