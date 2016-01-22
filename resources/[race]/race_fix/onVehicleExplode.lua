addEventHandler("onVehicleExplode", root, 
function()
	if isVehicleOnGround(source) then
		triggerClientEvent(root, "createPostExplosionEffect", root, source)
	end
end
)