-----------------
-- Items stuff --
-----------------

local ID = 2
local respawntime = 1000
local saferespawn = 1000
function loadGCRespawn ( player, bool, settings )
	if bool then
		setElementData(player, 'gcshop.respawntime', respawntime)
		setElementData(player, 'gcshop.saferespawn', saferespawn)
	else
		setElementData(player, 'gcshop.respawntime', nil)
		setElementData(player, 'gcshop.saferespawn', nil)
	end
end


-------------------
-- Respawn stuff --
-------------------

addEventHandler('onResourceStop', resourceRoot, function()
	for _, player in ipairs(getElementsByType'player') do
		setElementData(player, 'gcshop.respawntime', nil)
		setElementData(player, 'gcshop.saferespawn', nil)
	end
end)
