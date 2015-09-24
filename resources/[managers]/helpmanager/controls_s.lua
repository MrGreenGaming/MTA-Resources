
addEventHandler ( "onElementModelChange", root, 
function(oldid, newid)
	if getElementType(source) ~= "vehicle" then return end
	local p = getVehicleController(source)
	if isElement(p) then
		triggerClientEvent(p, "onClientVehicleChange",source, oldid,newid)
	end
end
)

addEvent("onPlayerPickUpRacePickup")
addEventHandler ( "onPlayerPickUpRacePickup", root, 
function(_, type)
	local p = source
	if type == "nitro" then
		triggerClientEvent(p, "onClientPickUpNitro",source)
	end
end
)

addEvent("onGamemodeMapStart")
addEventHandler ( "onGamemodeMapStart", root, 
	function()
		triggerClientEvent( "onGamemodeMapStart",root)
	end
)