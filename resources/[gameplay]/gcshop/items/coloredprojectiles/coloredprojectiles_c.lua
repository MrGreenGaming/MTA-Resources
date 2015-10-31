local ball = dxCreateTexture("items/coloredprojectiles/texture.png")

function attachMarkerToProjectile()
	for _, proj in ipairs(getElementsByType("projectile")) do
		local color = getElementData(proj,"color")
		if color then
			local x,y,z = getElementPosition(proj)
			setCoronaPosition(color[1],x,y,z)
			setCoronaPosition(color[2],x,y,z)
			
		end
	end
end
addEventHandler("onClientPreRender",root,attachMarkerToProjectile)

function setProjectileColour(creator)

	if creator and getElementType(creator) == "vehicle" then
		local creator = getVehicleOccupant( creator )
		local gcProjectileColor = getElementData(creator,"gc_projectilecolor")
		if gcProjectileColor and type(gcProjectileColor) == "string" then
			local r,g,b = hex2rgb(gcProjectileColor)

			local x,y,z = getElementPosition(source)

			local texture = createMaterialCorona(ball,x,y,z,0.8,r,g,b,40)
			local marker = createCorona(x,y,z,5,r,g,b,50)

			local t = {texture,marker}
			setElementData(source,"color",t,false)
		end
	end

end
addEventHandler("onClientProjectileCreation",root,setProjectileColour)

function removeProjectileColour()
	if source and getElementType(source) == "projectile" then
		local colorElement = getElementData(source,"color")
		if colorElement then
			destroyCorona(colorElement[1])
			destroyCorona(colorElement[2])
		end
	end
end
addEventHandler("onClientElementDestroy",root,removeProjectileColour)

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end