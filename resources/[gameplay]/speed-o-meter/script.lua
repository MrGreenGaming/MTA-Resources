digital = dxCreateFont( "digital.ttf", 20 ) or "default"

local offsetxSetting = 0
local offsetySetting = 0

function mph()
	local target = getCameraTarget()
	car = getPedOccupiedVehicle(getLocalPlayer())
	if target and getElementType(target) == "vehicle" then
		car = target
	end
	if car then
		if (getVehicleType(car) == "Plane") or (getVehicleType(car) == "Boat") or (getVehicleType(car) == "Helicopter") then
			xx,yy,zz = getElementVelocity(car)
			speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100
			speednumber = speednumber/1.15
			speednumber = math.floor(speednumber)
			speed = tostring(speednumber.." Knots") 
			x,y = guiGetScreenSize()
		dxDrawText( speed, x, y, x-73.5 - offsetxSetting, 151.5 + offsetySetting, tocolor ( 0, 0, 0, 150 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( speed, x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 255 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( "000 Knots", x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 40 ), 1, digital, "right", "bottom", false, false)
		else
		 xx,yy,zz = getElementVelocity(car)
		 speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100
		 speednumber = math.floor(speednumber)
		 speed = tostring(speednumber.." MPh") 
		 x,y = guiGetScreenSize()
		dxDrawText( speed, x, y, x-73.5 - offsetxSetting, 151.5 + offsetySetting, tocolor ( 0, 0, 0, 150 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( speed, x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 255 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( "000 MPH", x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 40 ), 1, digital, "right", "bottom", false, false)
		end
	end	
end

function kmh()
	local target = getCameraTarget()
	car = getPedOccupiedVehicle(getLocalPlayer())
	if target and getElementType(target) == "vehicle" then
		car = target
	end
	if car then
		if (getVehicleType(car) == "Plane") or (getVehicleType(car) == "Boat") or (getVehicleType(car) == "Helicopter") then
			xx,yy,zz = getElementVelocity(car)
			speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100
			speednumber = speednumber/1.15
			speednumber = math.floor(speednumber)
			speed = tostring(speednumber.." Knots") 
			x,y = guiGetScreenSize()
		dxDrawText( speed, x, y, x-73.5 - offsetxSetting, 151.5 + offsetySetting, tocolor ( 0, 0, 0, 150 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( speed, x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 255 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( "000 Knots", x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 40 ), 1, digital, "right", "bottom", false, false)
		else
		 xx,yy,zz = getElementVelocity(car)
		 speednumber = getDistanceBetweenPoints3D(0,0,0,getElementVelocity(car))*100*1.61
		 speednumber = math.floor(speednumber)
		 speed = tostring(speednumber.." KMh") 
		 x,y = guiGetScreenSize()
		dxDrawText( speed, x, y, x-73.5 - offsetxSetting, 151.5 + offsetySetting, tocolor ( 0, 0, 0, 150 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( speed, x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 255 ), 1, digital, "right", "bottom", false, false)
		dxDrawText( "000 KMH", x, y, x-72 - offsetxSetting, 150 + offsetySetting, tocolor ( 255, 255, 255, 40 ), 1, digital, "right", "bottom", false, false)
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

addCommandHandler('speedX',
function(commandName, offsetx)
	node = xmlLoadFile("settings.xml")
	if not node then
		node = xmlCreateFile("settings.xml", "mynode")
	end
	if offsetx then
		xmlNodeSetAttribute(node, "offsetx", offsetx)
		offsetxSetting = offsetx
	end
	xmlSaveFile(node)
	xmlUnloadFile(node)
end
, false, false)

addCommandHandler('speedY',
function(commandName, offsety)
	node = xmlLoadFile("settings.xml")
	if not node then
		node = xmlCreateFile("settings.xml", "mynode")
	end
	if offsety then
		xmlNodeSetAttribute(node, "offsety", offsety)
		offsetySetting = offsety
	end
	xmlSaveFile(node)
	xmlUnloadFile(node)
end
, false, false)



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

				if xmlNodeGetAttribute(node, "offsety") then
					offsetySetting = xmlNodeGetAttribute(node, "offsety")
				end
				if xmlNodeGetAttribute(node, "offsetx") then
					offsetxSetting = xmlNodeGetAttribute(node, "offsetx")
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

	removeEventHandler("onClientRender",getRootElement(), kmh)
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
	
	removeEventHandler("onClientRender",getRootElement(), mph)
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
