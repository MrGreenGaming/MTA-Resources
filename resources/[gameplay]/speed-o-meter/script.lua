function mph()
	car = getPedOccupiedVehicle(getLocalPlayer())
	if car then
		if (getVehicleType(car) == "Plane") or (getVehicleType(car) == "Boat") or (getVehicleType(car) == "Helicopter") then
			xx,yy,zz = getElementVelocity(car)
			speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100
			speednumber = speednumber/1.15
			speednumber = math.floor(speednumber)
			speed = tostring(speednumber.." Knots") 
			x,y = guiGetScreenSize()
			dxDrawText( speed, x, y, x-72, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
			dxDrawText( speed, x, y, x-68, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
			dxDrawText( speed, x, y, x-72, 149, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
			dxDrawText( speed, x, y, x-68, 151, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
			dxDrawText( speed, x, y, x-70, 150, tocolor ( 255, 255, 255, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
		else
		 xx,yy,zz = getElementVelocity(car)
		 speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100
		 speednumber = math.floor(speednumber)
	     speed = tostring(speednumber.." MPh") 
		 x,y = guiGetScreenSize()
		dxDrawText( speed, x, 150, x-72, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
		dxDrawText( speed, x, 150, x-68, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
		dxDrawText( speed, x, 150, x-72, 149, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
		dxDrawText( speed, x, 150, x-68, 151, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
		dxDrawText( speed, x, 150, x-70, 150, tocolor ( 255, 255, 255, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)	
		end
	end	
end

function kmh()
	car = getPedOccupiedVehicle(getLocalPlayer())
	if car then
		if (getVehicleType(car) == "Plane") or (getVehicleType(car) == "Boat") or (getVehicleType(car) == "Helicopter") then
			xx,yy,zz = getElementVelocity(car)
			speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100
			speednumber = speednumber/1.15
			speednumber = math.floor(speednumber)
			speed = tostring(speednumber.." Knots") 
			x,y = guiGetScreenSize()
			dxDrawText( speed, x, y, x-72, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
			dxDrawText( speed, x, y, x-68, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
			dxDrawText( speed, x, y, x-72, 149, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
			dxDrawText( speed, x, y, x-68, 151, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
			dxDrawText( speed, x, y, x-70, 150, tocolor ( 255, 255, 255, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
		else
		 xx,yy,zz = getElementVelocity(car)
		 speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100*1.61
		 speednumber = math.floor(speednumber)
	     speed = tostring(speednumber.." KMh") 
		 x,y = guiGetScreenSize()
		dxDrawText( speed, x, y, x-72, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
		dxDrawText( speed, x, y, x-68, 150, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
		dxDrawText( speed, x, y, x-72, 149, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false) 
		dxDrawText( speed, x, y, x-68, 151, tocolor ( 0, 0, 0, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
		dxDrawText( speed, x, y, x-70, 150, tocolor ( 255, 255, 255, 255 ), 0.8, 'bankgothic', "right", "bottom", false, false, false)
	end	
	end
end

addCommandHandler('mode',
function(commandName,par)
	node = xmlLoadFile("settings.xml")
	if not node then
		node = xmlCreateFile("settings.xml","mynode")
	end
	if par == "kmh" then
		addEventHandler("onClientRender",getRootElement(), kmh)
		removeEventHandler("onClientRender",getRootElement(), mph)
		outputChatBox('Mode changed to KMh')
		xmlNodeSetAttribute(node, "setting", par)
	elseif par == "mph" then
		addEventHandler("onClientRender",getRootElement(), mph)
		removeEventHandler("onClientRender",getRootElement(), kmh)
		outputChatBox('Mode changed to MPh')
		xmlNodeSetAttribute(node, "setting", par)
	elseif par == "none" then
		removeEventHandler("onClientRender",getRootElement(), mph)
		removeEventHandler("onClientRender",getRootElement(), kmh)
		xmlNodeSetAttribute(node, "setting", par)
		outputChatBox('The Speedometer has been disabled')
	else
		outputChatBox('Type /mode kmh or mph or none!')
	end
	xmlSaveFile(node)
	xmlUnloadFile(node)
end
)



addEventHandler('onClientResourceStart', getResourceRootElement(getThisResource()),
function()
	screenWidth, screenHeight = guiGetScreenSize()
		addEventHandler("onClientRender",getRootElement(), kmh)
		node = xmlLoadFile("settings.xml")
		if node then
				if xmlNodeGetAttribute(node, "setting") == "mph" then
					removeEventHandler("onClientRender",getRootElement(), kmh)
					addEventHandler("onClientRender",getRootElement(), mph)
				elseif xmlNodeGetAttribute(node, "setting") == "none" then
					removeEventHandler("onClientRender",getRootElement(), kmh)
					removeEventHandler("onClientRender",getRootElement(), mph)
				end
				xmlUnloadFile(node)
		end		
end
)	




-- Exported function for settings menu, KaliBwoy
function setKMH()
	node = xmlLoadFile("settings.xml")
	if not node then
		node = xmlCreateFile("settings.xml","mynode")
	end

	addEventHandler("onClientRender",getRootElement(), kmh)
	removeEventHandler("onClientRender",getRootElement(), mph)
	xmlNodeSetAttribute(node, "setting", "kmh")

	xmlSaveFile(node)
	xmlUnloadFile(node)
end
function setMPH()
	node = xmlLoadFile("settings.xml")
	if not node then
		node = xmlCreateFile("settings.xml","mynode")
	end
	addEventHandler("onClientRender",getRootElement(), mph)
	removeEventHandler("onClientRender",getRootElement(), kmh)
	xmlNodeSetAttribute(node, "setting", "mph")

	xmlSaveFile(node)
	xmlUnloadFile(node)

end
function setNone()
	node = xmlLoadFile("settings.xml")
	if not node then
		node = xmlCreateFile("settings.xml","mynode")
	end

	removeEventHandler("onClientRender",getRootElement(), mph)
	removeEventHandler("onClientRender",getRootElement(), kmh)
	xmlNodeSetAttribute(node, "setting", "none")

	xmlSaveFile(node)
	xmlUnloadFile(node)
end