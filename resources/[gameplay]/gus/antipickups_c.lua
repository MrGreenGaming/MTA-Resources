addEvent("removeBannedPickups", true)
function removeThePickups(disallowedVehs)

	local pickups = exports["race"]:e_getPickups()
	count = 0
	for f, u in pairs(pickups) do
		if u["type"] == "vehiclechange" then
			for i, v in pairs(disallowedVehs) do

				if u["vehicle"] == v then
					setElementPosition(f, 0,0,-10000)
					setElementPosition(u["object"],0,0,-10000) -- Hides pickup to -10000 Z
					count = count+1
				end
			end
		end
	end
	if count > 0 then
		outputDebugString(tostring(count).." disallowed vehiclechange pickups removed.")
	end
end
addEventHandler("removeBannedPickups", resourceRoot, removeThePickups)