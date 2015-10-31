-----------------
-- Items stuff --
-----------------

local ID = 10


function loadProjectileColor ( player, bool )
	if bool then
		local color = getPlayerRocketColor(player)
		if not color then
			outputDebugString("Could not find Color for "..getPlayerName(player))
			insertPlayerRocketColorToDB(player)
			color = "00FF00"
		end
		
		setElementData(player,"gc_projectilecolor","#"..color) 
	else
		setElementData(player,"gc_projectilecolor",nil)
	end
end
