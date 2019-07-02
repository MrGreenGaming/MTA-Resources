-----------------
-- Items stuff --
-----------------

local ID = 10


function loadProjectileColor ( player, bool )
	if bool then
		getPlayerRocketColor(player, 
		function(color) 
			if not color then
				outputDebugString("Could not find Color for "..getPlayerName(player))
				insertPlayerRocketColorToDB(player)
				color = "00FF00"
			end
			
			setElementData(player,"gc_projectilecolor","#"..color)
		end)
	else
		setElementData(player,"gc_projectilecolor",nil)
	end
end
